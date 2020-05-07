function error_print()
    love.graphics.setFont(small_font)
     love.graphics.setColor(1,0,1,255)
    love.graphics.print('ITS here' ..main_msg,100,10)
end

function displayFPS()
    love.graphics.setFont(small_font)
     love.graphics.setColor(0,1,0,255)
    love.graphics.print('FPS:' ..tostring(love.timer.getFPS()),10,10)
end

function score_check(ball,player1,player2)
    serving_player = 0 
    if(ball.x <= 0 )then
        player2.score = player2.score + 1
        serving_player = 2
        ball:reset()
    elseif (ball.x >=VIRTUAL_WIDTH) then
        player1.score = player1.score + 1
        serving_player = 1
        ball:reset()
    end
    return serving_player
end

function game_end_check(player1,player2)
    player_win = 0
    if(player1.score == MAX_SCORE) then 
        player_win = 1
    elseif(player2.score == MAX_SCORE)then
        player_win = 2
    end
    return player_win        
end

function ball_final_y(ball , player_direction, x)
    final_y = 0
    if (player_direction == left)then
        final_y = (ball.y + ball.dy*((ball.x - x)/(-ball.dx)))
    elseif(player_direction == right)then
        final_y = (ball.y + ball.dy*((x - ball.x )/(ball.dx)))
    end    
    if(final_y < 0)then
        final_y = -final_y
    elseif(final_y >VIRTUAL_HEIGHT)then 
        final_y = VIRTUAL_HEIGHT - (final_y - VIRTUAL_HEIGHT)   
    end
    return final_y
end 