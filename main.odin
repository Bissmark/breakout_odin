package main

import "core:fmt"
import "core:log"
import SDL "vendor:sdl3"

Vec2 :: [2]f32

Game :: struct {
    window: ^SDL.Window,
    renderer: ^SDL.Renderer,
    event: SDL.Event,

    blocks: [60]Block,
}

Player :: struct {
    rect: SDL.FRect,
    speed: int,
    position: Vec2
}

Ball :: struct {
    rect: SDL.FRect,
    velocity: Vec2,
    position: Vec2,
    speed: f32
}

Block :: struct {
    rect: SDL.FRect,
    active: bool,
}

SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 720

initialize :: proc(game: ^Game, player: ^Player, ball: ^Ball) -> bool {
    game.window = SDL.CreateWindow("Breakout", SCREEN_WIDTH, SCREEN_HEIGHT, {})
    if game.window == nil {
        log.error("Failed to create window:", SDL.GetError())
        return false
    }

    game.renderer = SDL.CreateRenderer(game.window, nil)
    if game.renderer == nil {
        log.error("Failed to create renderer:", SDL.GetError())
        return false
    }

    SDL.SetRenderVSync(game.renderer, 1)

    cols :: 12
    rows :: 5
    padding :: 5
    block_w := f32(SCREEN_WIDTH - (padding * (cols + 1))) / cols

    for i in 0..<60 {
        x := i % cols
        y := i / cols
        game.blocks[i].rect.w = block_w
        game.blocks[i].rect.h = 30
        game.blocks[i].rect.x = f32(x) * (block_w + padding) + padding
        game.blocks[i].rect.y = f32(y) * (30 + padding) + padding
        game.blocks[i].active = true
    }

    player.rect.x = SCREEN_WIDTH / 2 - player.rect.w / 2
    player.rect.y = SCREEN_HEIGHT - (player.rect.h + 5)
    player.position.x = player.rect.x
    player.position.y = player.rect.y
    player.speed = 5

    ball.rect.x = SCREEN_WIDTH / 2 - (player.rect.w / 2 - 45)
    ball.rect.y = SCREEN_HEIGHT - (player.rect.h + 20)
    ball.position.x = ball.rect.x
    ball.position.y = ball.rect.y
    ball.velocity = {1, -1}
    ball.speed = 3.0

    return true
}

update :: proc(game: ^Game, player: ^Player, ball: ^Ball) {
    key_states := SDL.GetKeyboardState(nil);

    if key_states[SDL.Scancode.A] {
        player.position.x -= f32(player.speed)
        player.rect.x =  player.position.x
    }
    if key_states[SDL.Scancode.D] {
        player.position.x += f32(player.speed)
        player.rect.x =  player.position.x
    }

    ball.position += ball.velocity * ball.speed
    ball.rect.x = ball.position.x
    ball.rect.y = ball.position.y

    for &block in game.blocks {
        if block.active && SDL.HasRectIntersectionFloat(block.rect, ball.rect) {
            block.active = false;
            ball.velocity.y *= -1
            break
        }
    }

    if ball.position.x <= 0 {
        ball.velocity.x *= -1
    }
    if ball.position.x + ball.rect.w >= SCREEN_WIDTH {
        ball.velocity *= -1
    }
    if ball.position.y <= 0 {
        ball.velocity.y *= -1
    }
    if ball.position.y >= SCREEN_HEIGHT {
        fmt.printf("Game Over")
    }
    if SDL.HasRectIntersectionFloat(ball.rect, player.rect) {
        ball.velocity.y *= -1
    }
}

render_player :: proc(game: ^Game, player: ^Player) {
    player.rect.w = 100
    player.rect.h = 10

    SDL.SetRenderDrawColor(game.renderer, 255, 255, 255, 255)
    SDL.RenderFillRect(game.renderer, &player.rect)
}

render_blocks :: proc(game: ^Game) {
    for &block in game.blocks {
        if block.active {
            SDL.SetRenderDrawColor(game.renderer, 255, 255, 255, 255)
            SDL.RenderFillRect(game.renderer, &block.rect)
        }
    }
}

render_game_ball :: proc(game: ^Game, player: ^Player, ball: ^Ball) {
    ball.rect.w = 10
    ball.rect.h = 10

    SDL.SetRenderDrawColor(game.renderer, 255, 255, 255, 255)
    SDL.RenderFillRect(game.renderer, &ball.rect)
}

main_loop :: proc(game: ^Game, player: ^Player, ball: ^Ball) {
    for {
        for SDL.PollEvent(&game.event) {
            #partial switch game.event.type {
                case .QUIT:
                    return
                }
            }

            update(game, player, ball)
            SDL.SetRenderDrawColor(game.renderer, 0, 0, 0, 255)
            SDL.RenderClear(game.renderer)

            render_player(game, player)
            render_blocks(game)
            render_game_ball(game, player, ball)

            SDL.RenderPresent(game.renderer)
    }
}

main :: proc() {
    fmt.printf("hello world")

    game: Game
    player: Player
    ball: Ball

    if !initialize(&game, &player, &ball) do return
    main_loop(&game, &player, &ball)

    SDL.DestroyRenderer(game.renderer)
    SDL.DestroyWindow(game.window)
    SDL.Quit()
}