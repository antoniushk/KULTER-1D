# -*- coding: utf-8 -*-
"""
core_code2.py (v5.1)

Modul ini berisi semua fungsi inti untuk memuat, memproses,
dan memvisualisasikan data resistivitas. Versi ini mendukung plot
berdasarkan jarak UTM sebenarnya (sumbu x bawah) dengan lebar
batang yang tetap (fixed width), dan nama stasiun di sumbu x atas.
"""
import pathlib
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import matplotlib.ticker as ticker

# Penanda versi untuk memastikan notebook memuat file yang benar
print("core_code2.py version 5.1 loaded successfully.")

def create_custom_colormap(colors, boundaries, style='smooth'):
    """
    Membuat colormap kustom dari daftar warna dan batas.
    """
    if len(colors) != len(boundaries) - 1:
        raise ValueError("Jumlah batas harus satu lebih banyak dari jumlah warna.")
    
    norm = mcolors.BoundaryNorm(boundaries, len(colors))
    if style == 'smooth':
        # Create a temporary ListedColormap to get RGB values
        temp_cmap = mcolors.ListedColormap(colors)
        rgb_colors = temp_cmap(np.linspace(0, 1, len(colors)))
        
        # Normalize boundaries to the range [0, 1]
        norm_boundaries = (np.array(boundaries) - boundaries[0]) / (boundaries[-1] - boundaries[0])
        
        # Create the cdict for LinearSegmentedColormap
        cdict = {'red': [], 'green': [], 'blue': []}
        for i, bound in enumerate(norm_boundaries):
            if i < len(colors):
                r, g, b, _ = rgb_colors[i]
                cdict['red'].append([bound, r, r])
                cdict['green'].append([bound, g, g])
                cdict['blue'].append([bound, b, b])

        # Ensure the last color is included if there's a final boundary
        if len(norm_boundaries) == len(colors) + 1:
             r, g, b, _ = rgb_colors[-1]
             cdict['red'].append([norm_boundaries[-1], r, r])
             cdict['green'].append([norm_boundaries[-1], g, g])
             cdict['blue'].append([norm_boundaries[-1], b, b])

        custom_cmap = mcolors.LinearSegmentedColormap('custom_smooth', cdict)
    else: # 'discrete' style
        custom_cmap = mcolors.ListedColormap(colors)

    return custom_cmap, norm


def load_and_filter_locations(location_filename, stations_to_plot, station_col, 
                              sort_by_col, elevation_col, lat_col, lon_col, 
                              easting_col, northing_col,
                              delimiter=',', force_custom_order=False):
    """
    Memuat file lokasi, memfilternya, dan menghitung jarak kumulatif jika diperlukan.
    """
    file_path = pathlib.Path.cwd() / location_filename
    
    if not file_path.exists():
        print(f"ERROR: File lokasi stasiun '{location_filename}' tidak ditemukan.")
        return None, None

    try:
        df_all_locations = pd.read_csv(file_path, delimiter=delimiter)
        df_all_locations.columns = df_all_locations.columns.str.strip()
    except Exception as e:
        print(f"ERROR: Gagal membaca file CSV '{location_filename}'. Error: {e}")
        return None, None

    required_cols = [station_col, elevation_col, lat_col, lon_col]
    if force_custom_order:
        required_cols.extend([easting_col, northing_col])
    # For index-based sorting, sort_by_col is the station name column
    elif sort_by_col != 'cumulative_distance':
        required_cols.append(sort_by_col)

    # Check for missing columns
    missing = [col for col in required_cols if col not in df_all_locations.columns]
    if missing:
        print(f"ERROR: Kolom berikut tidak ditemukan di '{location_filename}': {missing}")
        print(f"Kolom yang tersedia: {df_all_locations.columns.tolist()}")
        return None, None
        
    df_filtered = df_all_locations[df_all_locations[station_col].isin(stations_to_plot)].copy()
    
    if df_filtered.empty:
        print(f"ERROR: Tidak ada stasiun dari daftar Anda yang ditemukan di '{location_filename}'.")
        return df_all_locations, None

    if force_custom_order:
        # Sort based on the provided list order
        df_filtered[station_col] = pd.Categorical(df_filtered[station_col], categories=stations_to_plot, ordered=True)
        df_sorted = df_filtered.sort_values(station_col).reset_index(drop=True)
        
        # Calculate cumulative distance from UTM coordinates
        eastings = df_sorted[easting_col].values
        northings = df_sorted[northing_col].values
        distances = np.sqrt(np.diff(eastings)**2 + np.diff(northings)**2)
        cumulative_distances = np.insert(np.cumsum(distances), 0, 0)
        df_sorted['cumulative_distance'] = cumulative_distances
        
        print("Stasiun diurutkan berdasarkan daftar kustom. Jarak dihitung sepanjang lintasan.")
    else:
        # Sort based on a specific column (e.g., latitude, longitude)
        df_sorted = df_filtered.sort_values(sort_by_col).reset_index(drop=True)
        print(f"Stasiun diurutkan berdasarkan '{sort_by_col}': {df_sorted[station_col].tolist()}")

    return df_all_locations, df_sorted


def load_station_inversion_data(sorted_station_df, station_col, rms_col_inv):
    """
    Memuat data inversi dari file-file CSV individual.
    """
    current_directory = pathlib.Path('.')
    all_station_data_list = []
    rms_data = {}
    
    for station_name in sorted_station_df[station_col]:
        file_path = current_directory / f"{station_name}.csv"
        try:
            df_station = pd.read_csv(file_path, delimiter=',')
            df_station.columns = df_station.columns.str.strip()
            df_station[station_col] = station_name
            all_station_data_list.append(df_station)
            
            if rms_col_inv in df_station.columns and not df_station[rms_col_inv].empty:
                rms_data[station_name] = df_station[rms_col_inv].iloc[0]
        except FileNotFoundError:
            print(f"Peringatan: File data untuk stasiun '{station_name}' tidak ditemukan. Stasiun ini akan dilewati.")
    
    if not all_station_data_list:
        print("ERROR: Tidak ada file data yang berhasil dimuat.")
        return None, None

    df_master_data = pd.concat(all_station_data_list, ignore_index=True)
    sorted_station_df['RMS'] = sorted_station_df[station_col].map(rms_data)
    return df_master_data, sorted_station_df

def plot_station_location_map(ax, all_stations_df, profile_stations_df, lon_col, lat_col, station_col, 
                              show_profile_labels, start_label, end_label,
                              define_manual_line=False, start_station_name=None, end_station_name=None):
    """Membuat plot peta lokasi stasiun."""
    ax.scatter(all_stations_df[lon_col], all_stations_df[lat_col], c='blue', label='Stasiun Lain', s=20, zorder=2)
    ax.scatter(profile_stations_df[lon_col], profile_stations_df[lat_col], c='red', label='Stasiun Penampang', s=40, zorder=3, edgecolors='black')
    
    start_stn_data = all_stations_df[all_stations_df[station_col] == start_station_name] if start_station_name else None
    end_stn_data = all_stations_df[all_stations_df[station_col] == end_station_name] if end_station_name else None

    if define_manual_line and start_stn_data is not None and not start_stn_data.empty and end_stn_data is not None and not end_stn_data.empty:
        start_lon, start_lat = start_stn_data[[lon_col, lat_col]].iloc[0]
        end_lon, end_lat = end_stn_data[[lon_col, lat_col]].iloc[0]
        ax.plot([start_lon, end_lon], [start_lat, end_lat], 'r--', zorder=2, lw=1.5, label='Garis Penampang')
    
    if show_profile_labels and start_stn_data is not None and not start_stn_data.empty:
        ax.text(start_stn_data[lon_col].iloc[0], start_stn_data[lat_col].iloc[0], f'  {start_label}', 
                fontsize=14, fontweight='bold', ha='left', va='center', color='black', zorder=5)
    
    if show_profile_labels and end_stn_data is not None and not end_stn_data.empty:
        ax.text(end_stn_data[lon_col].iloc[0], end_stn_data[lat_col].iloc[0], f"{end_label}  ", 
                fontsize=14, fontweight='bold', ha='right', va='center', color='black', zorder=5)

    for _, row in all_stations_df.iterrows():
        ax.text(row[lon_col] + 0.001, row[lat_col], row[station_col], fontsize=8, ha='left', va='center')
    
    ax.set_title('Peta Lokasi Stasiun')
    ax.set_xlabel('Longitude'); ax.set_ylabel('Latitude')
    ax.legend(); ax.grid(True, linestyle='--', alpha=0.6)
    ax.set_aspect('equal', adjustable='box')
    ax.xaxis.set_major_formatter(ticker.FormatStrFormatter('%.3f'))
    ax.yaxis.set_major_formatter(ticker.FormatStrFormatter('%.3f'))
    plt.setp(ax.get_xticklabels(), rotation=45, ha="right")

def plot_rms_vs_station_name(ax, df_unique_stations, station_col, is_distance_mode=False):
    """Membuat plot RMS error vs. nama stasiun atau jarak."""
    rms_col = 'RMS'
    if rms_col not in df_unique_stations.columns or df_unique_stations[rms_col].isnull().all():
        ax.text(0.5, 0.5, 'Data RMS tidak ditemukan', ha='center', va='center', transform=ax.transAxes)
        ax.set_title('RMS Error per Stasiun'); return
        
    rms_values = df_unique_stations[rms_col]
    
    if is_distance_mode and 'cumulative_distance' in df_unique_stations.columns:
        x_coords_plot = df_unique_stations['cumulative_distance']
        ax.set_xlabel("Nama stasiun")
        station_names = df_unique_stations[station_col].tolist()
        ax.set_xticks(x_coords_plot)
        ax.set_xticklabels(station_names, rotation=90, fontsize=9)
    else:
        x_coords_plot = np.arange(len(df_unique_stations))
        ax.set_xlabel("Indeks Stasiun")
        ax.set_xticks(x_coords_plot)
        ax.set_xticklabels(df_unique_stations[station_col], rotation=90, fontsize=9)

    ax.plot(x_coords_plot, rms_values, 'o-', markersize=8)
    ax.set_title('RMS Error per Stasiun')
    ax.set_ylabel('RMS Error')
    ax.grid(True, linestyle='--', alpha=0.6)
    ax.margins(x=0.05)


def plot_native_grid_section(ax, sorted_station_df, df_master_data,
                             x_axis_col, x_axis_label, station_col, elev_col,
                             depth_col, res_col, use_topo, cmap_name,
                             vmin, vmax, y_limits=None, log_scale=True,
                             bar_width_coord=200, log_y_axis=False, 
                             cbar_shrink=1.0, cbar_aspect=20, show_profile_labels=False,
                             start_label="A", end_label="A'",
                             use_custom_cmap=False, custom_colors=None, 
                             custom_boundaries=None, custom_cmap_style='smooth'):
    """
    Plot penampang resistivitas.
    Versi ini menggunakan sumbu-x berdasarkan jarak dan lebar batang tetap.
    """
    # --- Pemeriksaan Data ---
    numeric_res_values = pd.to_numeric(df_master_data[res_col], errors='coerce')
    valid_res_values = numeric_res_values.dropna()
    if valid_res_values.empty:
        ax.text(0.5, 0.5, 'Data Resistivitas Kosong', ha='center', va='center', color='red'); return
    if log_scale and valid_res_values.le(0).any():
        ax.text(0.5, 0.5, 'Data Tidak Valid untuk Skala Log', ha='center', va='center', color='red'); return

    # --- Pengaturan Colormap ---
    if use_custom_cmap and custom_colors and custom_boundaries:
        cmap, norm = create_custom_colormap(custom_colors, custom_boundaries, style=custom_cmap_style)
    else:
        cmap = plt.get_cmap(cmap_name)
        norm = mcolors.LogNorm(vmin=vmin, vmax=vmax) if log_scale else mcolors.Normalize(vmin, vmax)
    
    # --- Pengaturan Sumbu X ---
    station_names_sorted = sorted_station_df[station_col].tolist()
    x_coords_plot = sorted_station_df[x_axis_col].values
    
    # --- Plot Topografi ---
    elevations = sorted_station_df[elev_col].values
    ax.plot(x_coords_plot, elevations, color='black', lw=1.5, zorder=3)
    if show_profile_labels:
        ax.text(x_coords_plot[0], elevations[0], start_label, fontsize=14, fontweight='bold', ha='right', va='bottom', zorder=5)
        ax.text(x_coords_plot[-1], elevations[-1], end_label, fontsize=14, fontweight='bold', ha='left', va='bottom', zorder=5)
        
    # --- Plot Batang Resistivitas ---
    for i, station in sorted_station_df.iterrows():
        station_name = station[station_col]
        station_elev = station[elev_col]
        station_x = x_coords_plot[i]
        bar_width = bar_width_coord
        
        station_data = df_master_data[df_master_data[station_col] == station_name].sort_values(depth_col)
        if station_data.empty: continue
            
        depths = station_data[depth_col].values
        res_values = pd.to_numeric(station_data[res_col], errors='coerce').values
        res_values[res_values <= 0] = np.nan

        x_start = station_x - bar_width / 2
        
        if use_topo:
            cell_tops = station_elev - depths
            cell_bottoms = np.append(cell_tops[1:], cell_tops[-1] - (depths[-1] - depths[-2] if len(depths) > 1 else 50))
            y_coords = np.vstack([cell_tops, cell_bottoms]).T
        else:
            cell_tops = -depths
            cell_bottoms = -np.append(depths[1:], depths[-1] + (depths[-1] - depths[-2] if len(depths) > 1 else 50))
            y_coords = np.vstack([cell_bottoms, cell_tops]).T

        for j, res_val in enumerate(res_values):
            if np.isfinite(res_val):
                color = cmap(norm(res_val))
                rect = plt.Rectangle((x_start, y_coords[j, 1]), bar_width, y_coords[j, 0] - y_coords[j, 1], color=color)
                ax.add_patch(rect)

    # --- Pengaturan Tampilan Plot ---
    mappable = plt.cm.ScalarMappable(cmap=cmap, norm=norm)
    mappable.set_array([])
    cbar = plt.colorbar(mappable, ax=ax, orientation='vertical', pad=0.02, shrink=cbar_shrink, aspect=cbar_aspect)
    cbar.set_label(r'Resistivitas ($\Omega \cdot m$)', rotation=270, labelpad=15)
    
    y_axis_label = "Elevasi (m)" if use_topo else "Kedalaman (m)"
    ax.set_xlabel(x_axis_label); ax.set_ylabel(y_axis_label)
    ax.set_title('Penampang Resistivitas')
    
    if not use_topo:
        ax.invert_yaxis()
    if log_y_axis:
        ax.set_yscale('log')
        y_axis_label += " (Skala Log)"
        ax.set_ylabel(y_axis_label)
        if y_limits and y_limits[0] <= 0:
            y_limits = (1, y_limits[1])

    if y_limits:
        ax.set_ylim(y_limits)
    ax.margins(x=0.02)
    
    # Sumbu x atas untuk nama stasiun
    ax2 = ax.twiny()
    ax2.set_xlim(ax.get_xlim())
    ax2.set_xticks(x_coords_plot)
    ax2.set_xticklabels(station_names_sorted, rotation=90, fontsize=9)
    ax2.set_xlabel("Nama Stasiun")

