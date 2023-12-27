classdef getSpineClass < handle

    properties
        answer
    end

    methods
        function obj = getSpineClass()
        end

        function newAnswer = getManualClass(obj)
            obj.answer = 'stubby'; % defaults to stubby
            fig = uifigure;
            fig.Position(3:4) = [123 175];
            title = uitextarea(fig,"Value",'Please select the most plausible spine classification:');
            title.Position = [0 125 125 50];
            bg = uibuttongroup(fig,"SelectionChangedFcn",@changeAnswer,"Position",[0 25 125 100]);
            b1 = uiradiobutton(bg,"Text","stubby","Position",[10 72 100 22]);
            b2 = uiradiobutton(bg,"Text","mushroom","Position",[10 50 100 22]);
            b3 = uiradiobutton(bg,"Text","thin","Position",[10 28 100 22]);
            b4 = uiradiobutton(bg,"Text","filopodium","Position",[10 6 100 22]);
            bOK = uibutton(fig,'Text','OK','ButtonPushedFcn','close(gcbf)');
            bOK.Position = [0 0 125 25];

            newAnswer = obj.answer;

            function changeAnswer(obj,event)
                obj.answer = event.NewValue.Text;
            end
        end
        % 
        % function changeAnswer(obj,event)
        %     obj.answer = event.NewValue.Text;
        % end

    end
end