ball = Class{}

function ball:init()
    self.x = VIRTUAL_WIDTH/2
    self.y = VIRTUAL_HEIGHT/2
    self.w = ball_width
    self.h = ball_height
    self.dx = math.random(2) == 1 and 100 or -100
    self.dy = math.random(-50,50)
end

function ball:update(dt)
    collide = 0
    self.x = self.x + self.dx*dt
    self.y = self.y + self.dy*dt
    if self.y <= 0 then
        self.y=0
        self.dy = 0 -self.dy
        collide =1
    end

    if self.y >= (VIRTUAL_HEIGHT-ball_height) then
        self.y = (VIRTUAL_HEIGHT-ball_height)
        self.dy = 0 - self.dy
        collide = 1
    end
    return collide
end

function ball:reset()
    self.x = VIRTUAL_WIDTH/2
    self.y = VIRTUAL_HEIGHT/2
    self.dx = math.random(2) == 1 and 100 or -100
    self.dy = math.random(-50,50)
end

function ball:render()
    love.graphics.rectangle('fill',self.x,self.y,self.w,self.h)
end

function ball:collision_check(paddle)
    if (self.x > (paddle.x + paddle.w )) or (paddle.x > (self.x + self.w )) then
        return false;
    end
    if (self.y > (paddle.y + paddle.h )) or (paddle.y > (self.y + self.h )) then
        return false;
    end 
    return true    
end

function ball:collision_affect(ball_x)
    self.dx = -self.dx*1.03
    self.x = ball_x
    if self.dy < 0 then
        self.dy = -math.random(10, 150)
    else
        self.dy = math.random(10, 150)
    end
end

function ball:serving_stage(serving_player)
    self.dy = math.random(-50,50)
    if(serving_player == 1)then
        self.dx = 100   
    elseif(serving_player ==2) then
        self.dx = -100    
    end
end

