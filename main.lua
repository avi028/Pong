push = require 'push'
Class = require 'class'
require 'paddle'
require 'ball'
require 'utility'

-- modes 
MULTIPLAYER = 'Multiplayer'
SOLO = 'solo'

--Directions
left = 'LEFT'
right = 'RIGHT' 

--drive 
MANUAL ='mauanl'
AUTO = 'auto'

-- Dimensions 
WIDTH = 1280 
HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- player default status
player_left_x = 10
player_left_y = 30
player_left_score_posX = VIRTUAL_WIDTH/2 - 50
player_left_score_posY = VIRTUAL_HEIGHT /3

player_right_x = VIRTUAL_WIDTH - player_left_x
player_right_y = VIRTUAL_HEIGHT - player_left_y
player_right_score_posX = VIRTUAL_WIDTH/2 + 40
player_right_score_posY = VIRTUAL_HEIGHT /3

-- paddle default status 
paddle_height = 20
paddle_width = 5
paddle_speed = 200
paddle_max_posY = VIRTUAL_HEIGHT - 20
paddle_min_posY = 0

-- ball default status
ball_x = VIRTUAL_WIDTH/2
ball_y = VIRTUAL_HEIGHT/2
ball_dx =  100
ball_dy = 50
ball_width = 4
ball_height  = 4

-- misselenious 
MAX_SCORE = 5
main_msg = ''
serving_player = 0
player_win = 0

--[[
    VARIOUS STATES OF THE GAME
    0. intro -- initial screen
    1. menu -- menu screen 
	1. start -- initial game state 
	2. play  -- when the game starts
    3. serve -- when a goal happens and the striker gets a chance to restart the ball from center
    4. pause -- pause the game 
    5. done -- game finish state    
    ]]

intro = 'intro'    
menu = 'menu'
start = 'start'
serve = 'serve'
play = 'play'
pause = 'pause'
done = 'done'

-- variable which will define which step to take according to the state of the game .
game_state = intro

function love.load()
	love.graphics.setDefaultFilter('nearest','nearest')
    --Set Window Title
    love.window.setTitle('Pong')
    -- seeding the randomnumber generator 
	math.randomseed(os.time())	
	-- 	font initialization for usage in the game 
	small_font = love.graphics.newFont('font.ttf',8)
    large_font = love.graphics.newFont('font.ttf',16)
    score_font = love.graphics.newFont('font.ttf',32)
	--  using push library setupSrancreen Function instead of default to automaticaly 
	--  handle resize issues
    push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WIDTH,HEIGHT,
            {fullscreen = false,resizable = false,vsync = true})
    -- sound loading
    sounds = {['intro'] = love.audio.newSource('music/intro.wav','stream'),
            ['inplay'] = love.audio.newSource('music/inplay.wav','stream'),
            ['shot'] = love.audio.newSource('music/shot.wav','static'),
            ['score'] = love.audio.newSource('music/score.wav','static'),
            ['win'] = love.audio.newSource('music/win.wav','stream'),
            ['hit'] = love.audio.newSource('music/hit.wav','static')
        }
    -- characters initialization 
    player_left = paddle(player_left_x,player_left_y,paddle_width,paddle_height,MANUAL)        
    player_right = paddle(player_right_x,player_right_y,paddle_width,paddle_height,MANUAL)
    ball = ball()
    -- variables initialization 
    serving_player =0 
    player_win = 0
    game_state = intro
    sounds['intro']:play()
end 

function love.keypressed(key)
    
    if key == 'escape' then
        if game_state == intro then
            game_state = menu
        elseif(game_state == pause)then
            game_state = play
        elseif(game_state == play) then
            game_state = pause
        end
    elseif key == 'q' or key == 'Q' then
        if game_state == intro then
            game_state = menu
        elseif game_state == menu then
            sounds['intro']:stop()
            love.event.quit()    
        elseif game_state == start or game_state == done or game_state == pause then
            game_state = menu
         --   sounds['inplay']:stop()
            sounds['win']:stop()
            sounds['intro']:play()
        end    
	elseif key == 'enter' or key == 'return' then
        if game_state == intro then
            game_state = menu            
        elseif game_state == start then 
            game_state = serve
      --      sounds['inplay']:play()
            if(serving_player ==0)then
                serving_player = math.random(1,2)
            end
        elseif game_state == serve then
            sounds['score']:stop()
            sounds['win']:stop()
            game_state = play      
        elseif game_state == play then
            game_state = pause
        elseif game_state == pause then
			game_state = start
            ball:reset()
            player_left:reset()
            player_right:reset()
            serving_player =0 
            player_win = 0
          --  sounds['inplay']:stop()
        elseif game_state == done then
			game_state = serve
            sounds['win']:stop()
            --sounds['inplay']:play()
            ball:reset()
            player_left:reset()
            player_right:reset()
            serving_player = math.random(1,2)
            player_win = 0
        end
    elseif key == '1' then
        if game_state == menu then
            ball:reset()
            player_left:reset()
            player_right:reset()
            serving_player =0 
            player_win = 0

            game_state = start 
            sounds['intro']:stop()
            mode = MULTIPLAYER
            player_left:change_drive(MANUAL)
            player_right:change_drive(MANUAL)
        end
    elseif key == '2' then
        if game_state == menu then
            ball:reset()
            player_left:reset()
            player_right:reset()
            serving_player =0 
            player_win = 0

            game_state = start
            sounds['intro']:stop()
            mode = SOLO
            player_left:change_drive(AUTO)
            player_right:change_drive(MANUAL)
        end
    else
        if game_state == intro then
            game_state = menu
        end    
	end	
end

--[[ MOVEMENT DESCRIPTION
    upward movement means going back to y = 0 i.e top of screen 
    downward movement means going towards end of screen bottom of screen 
    ]]
--[[ KEYS FOR GAME CONTROL 
    player 1 keys  
        w => upward movement 
        s => downward movement 

    player 2 keys  
        up arrow    => upward movement 
        down arrow  => downward movement 
    ]]

function love.update(dt)
    if game_state ==serve then
        ball:serving_stage(serving_player)
    elseif game_state == play then
        if(ball:collision_check(player_left))then
            ball:collision_affect(player_left.x + 5)
            sounds['shot']:play()
        end
        if(ball:collision_check(player_right))then
            ball:collision_affect(player_right.x - 4)    
            sounds['shot']:play()
        end
        serving_player = score_check(ball,player_left,player_right)
        player_win = game_end_check(player_left,player_right)
        if(player_win ~= 0) then
            game_state = done
        --    sounds['inplay']:stop()
            sounds['win']:play()
        elseif(serving_player ~=0 )then
            sounds['score']:play()
            game_state=serve
        end
        -- used to detect colision of the ball and give a wall hit sound
        collide = ball:update(dt)
        if(collide == 1)then
            sounds['hit']:play()
        end
        if(player_left.drive == AUTO)then
            if(ball.dx < 0) then
                final_y_left =  ball_final_y(ball , left, player_left_x)                
                -- HARD
                if(player_left.y-final_y   > ball_width/2) then  --player_left-final_y   > ball_width/2  
                -- EASY
                -- if(player_left.y-final_y   > paddle_height) then  --player_left-final_y   > paddle.height  
                    player_left.dy = -paddle_speed
                    player_left:update(dt)
                -- HARD
                elseif ( final_y - player_left.y > ball_width/2)then -- final_y - player_left > ball_width/2 
                --EASY
                --elseif ( final_y - player_left.y > paddle_height)then -- final_y - player_left > paddle.height 
                    player_left.dy = paddle_speed
                    player_left:update(dt)
                elseif(player_left.y == final_y)then
                    player_left.dy =0 
                end
            end
        end
        if(player_right.drive == AUTO)then
            if(ball.dx > 0) then
                final_y_right =  ball_final_y(ball , right, player_right_x)
                if(player_right.y > final_y_right)then
                    player_right.dy = -paddle_speed
                elseif (player_right.y < final_y_right)then
                    player_right.dy = paddle_speed
                elseif(player_right.y == final_y_right)then
                    player_right.dy = 0
                end
                player_right:update(dt)
            end            
        end

    end
    if(game_state ~= pause and game_state ~= intro and game_state~=menu)then
        -- player_left paddle update logic 
        if(player_left.drive == MANUAL)then
            if love.keyboard.isDown('w') then 
                player_left.dy = -paddle_speed 
            elseif love.keyboard.isDown('s') then 
                player_left.dy = paddle_speed 
            else
                player_left.dy = 0
            end
            player_left:update(dt)
        end    
        -- player_right paddle update logic
        if (player_right.drive == MANUAL)then 
            if love.keyboard.isDown('up') then 
                player_right.dy = -paddle_speed 
            elseif love.keyboard.isDown('down') then 
                player_right.dy = paddle_speed 
            else
                player_right.dy = 0
            end
            player_right:update(dt)
        end
    end
end

function love.draw()
    push:start()
    love.graphics.clear()
    love.graphics.setFont(small_font)
    
    if game_state == intro then
        love.graphics.setFont(score_font)
        love.graphics.printf('PONG',0,30,VIRTUAL_WIDTH,'center')
        love.graphics.setFont(small_font)
        love.graphics.printf('Press any key to start',0,80,VIRTUAL_WIDTH,'center')
    elseif game_state == menu then
        love.graphics.setFont(small_font)
        love.graphics.printf('1 -   MULTIPLAYER',0,70,VIRTUAL_WIDTH,'center')
        love.graphics.printf('2       -   SOLO',0,80,VIRTUAL_WIDTH,'center')
        love.graphics.printf('Q       -   QUIT',0,90,VIRTUAL_WIDTH,'center')
        love.graphics.printf('PLEASE SELECT AN OPTION TO CONTINUE',0,120,VIRTUAL_WIDTH,'center')
    elseif game_state == start then
        love.graphics.setFont(small_font)
        if mode == MULTIPLAYER then
    	    love.graphics.printf('ONE ON ONE \n', 0,10,VIRTUAL_WIDTH,'center')
    	    love.graphics.printf('PLAYER LEFT CONTROLS \n W - MOVE UP ||  S - MOVE DOWN ', 0,30,VIRTUAL_WIDTH,'center')
            love.graphics.printf('PLAYER RIGHT CONTROLS \n ARROW-KEY-UP - MOVE UP  ||  ARROW-KEY_DOWN - MOVE DOWN \n PRESS ENTER TO CONTINUE ', 0,70,VIRTUAL_WIDTH,'center')
        elseif mode == SOLO then
    	    love.graphics.printf('MACHINE VS U \n', 0,10,VIRTUAL_WIDTH,'center')
            love.graphics.printf('PLAYER CONTROLS \n ARROW-KEY-UP - MOVE UP \n ARROW-KEY_DOWN - MOVE DOWN \n PRESS ENTER TO CONTINUE ', 0,30,VIRTUAL_WIDTH,'center')
        end
    elseif(game_state == serve)then
	    love.graphics.printf('Player ' ..tostring(serving_player) ..'"s serving', 0,20,VIRTUAL_WIDTH,'center')	
	    love.graphics.printf('Press enter to serve', 0,30,VIRTUAL_WIDTH,'center')	
    elseif(game_state == play)then
	    love.graphics.printf('Press escape to pause', 0,20,VIRTUAL_WIDTH,'center')	
    elseif(game_state == pause)then
	    love.graphics.printf('Press escape to play', 0,20,VIRTUAL_WIDTH,'center')	
	    love.graphics.printf('Press enter to restart', 0,30,VIRTUAL_WIDTH,'center')	
	    love.graphics.printf('Press Q to quit', 0,40,VIRTUAL_WIDTH,'center')	
    elseif(game_state == done)then
        love.graphics.setFont(large_font)
        love.graphics.printf('Congratulations !! Player ' ..tostring(player_win) ..' . \n You win this round',0,20,VIRTUAL_WIDTH,'center')
        love.graphics.setFont(small_font)
        love.graphics.printf('Press enter to restart the Game',0,60,VIRTUAL_WIDTH,'center')    
	    love.graphics.printf('Press Q to quit',0, 70,VIRTUAL_WIDTH,'center')	
    end	
    if(game_state ~= intro and game_state ~=menu and game_state ~=start) then
	    love.graphics.setFont(score_font)
        love.graphics.print(tostring(player_left.score),player_left_score_posX,player_left_score_posY )
        love.graphics.print(tostring(player_right.score),player_right_score_posX,player_right_score_posY )
    end

    if(game_state ~= done and game_state ~= intro and game_state~= menu)then
        -- paddle one 
        player_left:render()
        -- paddle two 
        player_right:render()
        -- ball 
        if game_state ~= start then
            ball:render()
        end
    end    
    displayFPS()
    push:finish()
end
