--[[
    Gaming Setup...
]]
push = require 'push' --require the library

Class = require 'class'

require 'Ball'
require 'Paddle'


WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432 
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200 


function love.load()

    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle("Pong")


    largeFont = love.graphics.newFont('font.ttf', 14)
    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 16)
    mediumFont = love.graphics.newFont('font.ttf', 11)
    elargeFont = love.graphics.newFont('font.ttf', 20)


    math.randomseed(os.time())
    
    love.graphics.setFont(smallFont) 

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['win'] = love.audio.newSource('sounds/win.wav', 'static')
    }
    push:setupScreen( VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true 
    })

    player1score = 0
    player2score = 0
    servingPlayer = 1
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 15 , VIRTUAL_HEIGHT - 30, 5, 20)
    ball = Ball(VIRTUAL_WIDTH / 2 - 2 , VIRTUAL_HEIGHT / 2 - 2, 4, 4)
    gamestate = 'start'

end

function love.resize(w,h)
    push:resize(w,h)
end


function love.keypressed(key)

    if key == 'escape' then 
        love.event.quit()
    elseif key == 'return' or key == 'space' or key == 'enter'then
        if gamestate == 'start' then
            gamestate = 'serve'
        elseif gamestate == 'serve' then
            gamestate = 'play'
        elseif gamestate == 'done' then
            gamestate = 'serve'
            ball:reset()


            player1score = 0
            player2score = 0


            if winningPlayer == 1 then
                servingPlayer = 2
            else 
                servingPlayer = 1
            end
        end
    end
end

--[[
    Drawing anything onto the screen...
]]


function love.update(dt)


    if gamestate == 'play' then
        ball:update(dt)

        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5  
            sounds['paddle_hit']:play()

            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else 
                ball.dy = math.random(10,150)
            end
        end

        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4  
            sounds['paddle_hit']:play()

            if ball.dy < 0 then
                ball.dy = -math.random(10,150)
            else 
                ball.dy = math.random(10,150)
            end
        end

        if ball.y <= 0 then 
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end
        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end        
    end


    if ball.x < 0 then 
        servingPlayer = 1
        player2score = player2score + 1
        sounds['score']:play()
        if player2score >= 10 then
            winningPlayer = 2
            sounds['win']:play()
            gamestate = 'done'
        else 
            gamestate = 'serve'
        ball:reset()
        end
    end

    if ball.x > VIRTUAL_WIDTH then 
        servingPlayer = 2
        player1score = player1score + 1
        sounds['score']:play()
        if player1score >= 10 then
            winningPlayer = 1
            sounds['win']:play()
            gamestate = 'done'
        else 
            gamestate = 'serve'
        end
        ball:reset()
    end

    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end 

    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else 
        player2.dy = 0
    end

    player1:update(dt)
    player2:update(dt)

end


function love.draw()

    push:apply('start')
    love.graphics.clear(0.11,0.11,0.19,255)
    displayscore()

    if gamestate == 'start' then
        love.graphics.setFont(largeFont)
        love.graphics.printf("Welcome to the PONG!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to start", 0, 28, VIRTUAL_WIDTH, 'center')
    elseif gamestate == 'serve' then
        love.graphics.setFont(mediumFont)
        love.graphics.printf("Player "..tostring(servingPlayer).." serve", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to serve", 0, 24, VIRTUAL_WIDTH, 'center')
    elseif gamestate == 'play' then
    elseif gamestate == 'done' then
        love.graphics.setFont(elargeFont)
        love.graphics.printf('Player '..tostring(winningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to restart", 0, 30, VIRTUAL_WIDTH, 'center')
    end

    -- first rectangle
    player1:render()

    --second rectangle
    player2:render()
    
    --ball
    ball:render()

    displayFPS()
    push:apply('end')
end


function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 10, 10)
end


function displayscore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(player1score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(player2score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end