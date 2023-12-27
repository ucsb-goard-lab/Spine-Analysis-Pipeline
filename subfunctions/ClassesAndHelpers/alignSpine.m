function hIm = alignSpine(im,save_name)
            im = imread(im);
            hIm = imshow(im);
            sz = size(im);
            pos = [(sz(2)/4) + 0.5, (sz(1)/4) + 0.5, sz(2)/2, sz(1)/2]; 
            h = drawrectangle('Rotatable',true,...
                'DrawingArea','unlimited',...
                'Position',pos,...
                'FaceAlpha',0);
            h.Label = 'Rotate rectangle to rotate image';
            addlistener(h,'MovingROI',@(src,evt) rotateImage(src,evt,hIm,im));
            customWait(h);%cutsomWait function by Kevin Sit
            h.Visible = 'off';
            saveas(hIm,save_name,'jpg');
end
