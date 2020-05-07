--Class = require 'class'
paddle = Class{}

function paddle:init(x,y,width,height,drive)
    self.init_x = x
    self.init_y = y
    self.x = x
    self.y = y
    self.w = width
    self.h = height
    self.dy = 0
    self.score=0
    self.drive =  drive
end

function paddle:change_drive(drive)
    self.drive = drive
end 

function paddle:update(dt)
    self.y = self.y + self.dy * dt
    if self.y < paddle_min_posY then
        self.y = paddle_min_posY
    elseif self.y > paddle_max_posY then 
        self.y = paddle_max_posY    
    end
end

function paddle:render()
    love.graphics.rectangle('fill',self.x,self.y,self.w,self.h) 
end

function paddle:reset()
    self.x = self.init_x
    self.y = self.init_y
    self.dy = 0
    self.score=0
end

