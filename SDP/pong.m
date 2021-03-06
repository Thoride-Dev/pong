function [] = pong()
clc
clear
close all

%% -------------------Constants-------------------
%settings
maxScore = 5;
startDelay = 1;

%movement values
animSpeed = 0.01;
minBallSpeed = 0.8;
maxBallSpeed = 3;
ballAccel = 0.05;
paddleSpeed = 1.3;
goalDistance = 5;
b = 1;
p = 2;
y = 0.01;

%canvas layout
ballRadius = 1.5;
wallWidth = 3;
canvasWidth = 852;
canvasHeight = 480;
plotWidth = 150;
plotHeight = 100;
goalSize = 0;
goalTop = (plotHeight + goalSize)/2;
goalBottom = (plotHeight - goalSize)/2;
paddleHeight = 18;
paddleWidth = 3;
paddle = [0, paddleWidth, paddleWidth, 0, 0; paddleHeight, paddleHeight, 0, 0, paddleHeight];
paddleSpace = 10;

%canvas appearance
background = [0,0,0];
ballVisualSize  = 10;
ballColor = [1,1,1];
wallColor= [1,1,1];
paddleColor = [1,1,1];


%% -------------------Variables-------------------
canvas = [];
quit = false;
ballShape = 'o';
score = [];
winner = [];
ball = [];
p1Plot = [];
p2Plot = [];
ballVector = [];
ballSpeed = [];
ballX = [];
ballY = [];
p1V = [];
p2V = [];
p1 = [];
p2 = [];


%% Create Canvas Function
function createCanvas
    %create canvas screen
    screenSize = get(0,'ScreenSize');
    canvas = figure('Position', [(screenSize(3)-canvasWidth)/2 ...
        (screenSize(4)-canvasHeight)/2 ...
        canvasWidth, canvasHeight]);
    %initialize key press listeners
    set(canvas,'KeyPressFcn',@keyDown, 'KeyReleaseFcn', @keyUp);
    set(canvas, 'Resize', 'off');
    disableDefaultInteractivity(gca);
    axis([0, plotWidth, 0, plotHeight]);
    axis manual;
    %court coloring
    set(gca, 'color', [.15, .15, .15], 'YTick', [], 'XTick', []); 
    set(canvas, 'color', background);
    hold on;

    %wall creation
    topWallXs = [0, 0, plotWidth, plotWidth];
    topWallYs = [goalTop, plotHeight, plotHeight, goalTop];
    bottomWallXs = [0,0,plotWidth,plotWidth];
    bottomWallYs = [goalBottom,0,0,goalBottom];
    %plot them
    plot(topWallXs, topWallYs, '-', ...
      'LineWidth', wallWidth, 'Color', wallColor);
    plot(bottomWallXs, bottomWallYs, '-', ...
      'LineWidth', wallWidth, 'Color', wallColor);
    
    %ball plot
    ball = plot(0,0);
    set(ball, 'Marker', ballShape);
    set(ball, 'MarkerEdgeColor', ballColor);
    set(ball, 'MarkerFaceColor', ballColor);
    set(ball, 'MarkerSize', ballVisualSize);
    
    %paddles
    p1Plot = plot(0,0, '-', 'LineWidth', 2);
    p2Plot = plot(0,0, '-', 'LineWidth', 2);
    set(p1Plot, 'Color', paddleColor);
    set(p2Plot, 'Color', paddleColor);

end

%% Start Game script
    function startGame
        winner = 0;
        score = [0, 0];
        %paddle speeds
        p1V = 0;
        p2V = 0;
        %paddle positions
        p1 = [paddle(1,:) + paddleSpace; paddle(2,:)+((plotHeight - paddleHeight)/2)];
        p2 = [paddle(1,:)+plotWidth - paddleSpace - paddleWidth; paddle(2,:)+ ((plotHeight - paddleHeight)/2)];
        reset;
    end
%% Reset game
%resets ball location and paddle location, and updates scores

    function reset
        bounce([1-(2*rand), 1-(2*rand)]);
        ballSpeed = minBallSpeed;
        %center of screen starting pos
        ballX = plotWidth/2;
        ballY = plotHeight/2; 
        %score string
        titleStr = sprintf('%d / %d%19d / %d', ...
        score(1), maxScore, score(2), maxScore);
        t = title(titleStr, 'Color', 'w');
        set(t, 'FontName', 'Arial','FontSize', 15, 'FontWeight', 'Bold');
        refresh;
    end
        
%% move ball function
%the backbone of the pong script, this controls moving the ball
    function moveBall
        
        %paddle 1 boundries
        p1T = p1(2,1);
        p1B = p1(2,3);
        p1L = p1(1,1);
        p1R = p1(1,2);
        p1Center = ([p1L p1B] + [p1R p1T]) ./ 2;
        %paddle 2 boundries
        p2T = p2(2,1);
        p2B = p2(2,3);
        p2L = p2(1,1);
        p2R = p2(1,2);
        p2Center = ([p2L p2B] + [p2R p2T]) ./ 2;
        %update position
        newX = ballX + (ballSpeed * ballVector(1));
        newY = ballY + (ballSpeed * ballVector(2));
        
        
        %ball hit top wall
        if(newY > (plotHeight - ballRadius))
            bounce([ballVector(1), -1 * (y +abs(ballVector(2)))]);
        elseif (newY < ballRadius)
            bounce([ballVector(1), (y + abs(ballVector(2)))]);
          %hit paddle 1
        elseif (newX < p1R + ballRadius ...
            && newX > p1L - ballRadius ...
            && newY < p1T + ballRadius ...
            && newY > p1B - ballRadius)
          bounce([(ballX-p1Center(1)) * p, newY-p1Center(2)]);

          %hit paddle 2
        elseif (newX < p2R + ballRadius ...
            && newX > p2L - ballRadius ...
            && newY < p2T + ballRadius ...
            && newY > p2B - ballRadius)
          bounce([(ballX-p2Center(1)) * p, newY-p2Center(2)]);
        else
          %no hits
        end
        
        ballX = newX;
        ballY = newY;
    end

%% move paddles
%controls movement of paddles

    function movePaddles
        p1(2,:) = p1(2,:) + (paddleSpeed * p1V);
        p2(2,:) = p2(2,:) + (paddleSpeed *p2V);
        
        if p1(2,1) > plotHeight
            p1(2,:) = paddle(2,:) + plotHeight - paddleHeight;
        elseif p1(2,3) < 0 
            p1(2,:) = paddle(2,:);
        end
        if p2(2,1) > plotHeight
            p2(2,:) = paddle(2,:) + plotHeight - paddleHeight;
        elseif p2(2,3) < 0 
            p2(2,:) = paddle(2,:);
        end
    end

%% bounce function

    function bounce(tempV)
        %increase velocity by a random amount, b value to help the ball
        %stay more horizontal than vertical
        tempV(1) = tempV(1) * ((rand/b)+1);
        tempV = tempV ./ (sqrt(tempV(1)^2 + tempV(2)^2));
        ballVector = tempV;
        
        if(ballSpeed + ballAccel < maxBallSpeed)
            ballSpeed = ballSpeed + ballAccel;
        end
    end
%% goal
%controls goal checks
    function checkGoal
        goal = false;
        %ball scored right
        if (ballX > (plotWidth + ballRadius + goalDistance))
            score(1) = score(1) + 1;
            goal = true;
        %ball scored left
        elseif (ballX < (0 - ballRadius - goalDistance))
            score(2) = score(2) + 1;
            goal = true;
        end
        
        if(score(1) == maxScore)
            winner = 1;
        elseif(score(2) == maxScore)
            winner = 2;
        end
        
        if goal
            pause(startDelay)
            reset;
            if (winner == 1)
                winString = 'Player 1 won!';
                winText = text(plotWidth/2-20,plotHeight/2+20, winString);
                set(winText, 'FontSize', 20, 'FontWeight', 'Bold');
                set(winText, 'Color', 'w');
                pause(5);
                delete(winText);
                startGame;
            elseif(winner == 2)
                winString = 'Player 2 won!';
                winText = text(plotWidth/2-20,plotHeight/2+20, winString);
                set(winText, 'FontSize', 20, 'FontWeight', 'Bold');
                set(winText, 'Color', 'w');
                pause(5);
                delete(winText);
                startGame;
            end
        end 
    end

%% refresh plot

    function refresh
        %update plot by updated x and y values of moving objects
        set(ball,'XData', ballX, 'YData', ballY);
        set(p1Plot, 'XData', p1(1,:), 'YData', p1(2,:));
        set(p2Plot, 'XData', p2(1,:), 'YData', p2(2,:));
        drawnow;
        pause(animSpeed)
    end

%% key events
    function keyDown(src, event)
        switch event.Key
            case 'w'
                p1V = 1;
            case 's'
                p1V = -1;
            case 'uparrow'
                p2V = 1;
            case 'downarrow'
                p2V = -1;
            case 'q'
                quit = true;
            case 'escape'
                quit = true;
        end
    end
    %control players and quit events.
    function keyUp(src, event)
        switch event.Key
            case 'w'
                if p1V == 1
                    p1V = 0;
                end
            case 's'
                if p1V == -1
                    p1V = 0;
                end
            case 'uparrow'
                if p2V == 1
                    p2V = 0;
                end
            case 'downarrow'
                if p2V == -1
                    p2V = 0;
                end
        end 
    end
%% main
createCanvas;
startGame;
while ~quit
    moveBall;
    movePaddles;
    refresh;
    checkGoal;
end
close(canvas)
end
