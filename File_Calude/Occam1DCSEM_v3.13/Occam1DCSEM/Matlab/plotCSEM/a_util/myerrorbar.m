function h = myerrorbar(x,y,L,U,varargin)

 ii = isfinite(y);
 x = x(ii);
 y = y(ii);
 L = L(ii);
 U = U(ii);
 h1 = [];
 h0 = [];
 if size(x,1) < size(x,2)
     x = x';
 end
  if size(y,1) < size(y,2)
     y = y';
  end
  if size(L,1) < size(L,2)
     L = L';
  end
  if size(U,1) < size(U,2)
     U = U';
  end  
 if all(abs(L) > 0) && all(abs(U)>0)

    h1 = plot([x  x]',([y-abs(L) y+abs(U)]'), 'linestyle','-',varargin{:},'marker','none');
    hold on;
 end
 h0 = plot(x,y,varargin{:},'linestyle','none');
 hold on;
 h = [h0;h1];
 if isempty(h)
     h = 0;
 end
            