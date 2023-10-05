function drawCir(C,s,varargin)
    theta = -pi-0.01:0.1:pi;
    x = C(1) + s*cos(theta);
    y = C(2) + s*sin(theta);
    if nargin==2
        plot(x,y,'black')
        return
    end
    plot(x,y,varargin{1});

end