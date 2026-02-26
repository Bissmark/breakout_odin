package main

import "core:fmt"
import "core:log"
import SDL "vendor:sdl3"

Vec2 :: [2]f32

Game :: struct {
    window: ^SDL.Window,
    renderer: ^SDL.Renderer,
    event: SDL.Event,

    //player: SDL.FRect,
    block: SDL.FRect,
    //ball: SDL.FRect,
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

    // player.rect.w = 100
    // player.rect.h = 10
    player.rect.x = SCREEN_WIDTH / 2 - player.rect.w / 2
    player.rect.y = SCREEN_HEIGHT - (player.rect.h + 5)
    player.position.x = player.rect.x
    player.position.y = player.rect.y
    player.speed = 1

    ball.rect.x = SCREEN_WIDTH / 2 - (player.rect.w / 2 - 45)
    ball.rect.y = SCREEN_HEIGHT - (player.rect.h + 20)
    ball.position.x = ball.rect.x
    ball.position.y = ball.rect.y
    ball.velocity = {1, -1}
    ball.speed = 3.0

    return true
}

update :: proc(player: ^Player, ball: ^Ball) {
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

    // if ball.position.x < SCREEN_WIDTH {
    //     ball.velocity.x *= -1
    // }
}

render_player :: proc(game: ^Game, player: ^Player) {
    player.rect.w = 100
    player.rect.h = 10
    // player.rect.x = SCREEN_WIDTH / 2 - player.rect.w / 2
    // player.rect.y = SCREEN_HEIGHT - (player.rect.h + 5)
    // player.position.x = player.rect.x
    // player.position.y = player.rect.y

    SDL.SetRenderDrawColor(game.renderer, 255, 255, 255, 255)
    SDL.RenderFillRect(game.renderer, &player.rect)
}

render_blocks :: proc(game: ^Game) {
    cols :: 12
    padding :: 5
    block_w := f32(SCREEN_WIDTH - (padding * (cols + 1))) / cols

    for x in 0..<cols {
        for y in 0..<5 {
            game.block.w = block_w
            game.block.h = 30
            game.block.x = f32(x) * (block_w + padding) + padding
            game.block.y = f32(y) * (game.block.h + 5) + 5

            SDL.SetRenderDrawColor(game.renderer, 255, 255, 255, 255)
            SDL.RenderFillRect(game.renderer, &game.block)
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

            update(player, ball)
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