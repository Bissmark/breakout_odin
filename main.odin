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
    speed: int,
    position: Vec2,
}

SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 720

initialize :: proc(game: ^Game, player: ^Player) -> bool {
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

    // player.rect.w = 100
    // player.rect.h = 10
    player.rect.x = SCREEN_WIDTH / 2 - player.rect.w / 2
    player.rect.y = SCREEN_HEIGHT - (player.rect.h + 5)
    player.position.x = player.rect.x
    player.position.y = player.rect.y
    player.speed = 1

    return true
}

update :: proc(player: ^Player) {
    key_states := SDL.GetKeyboardState(nil);

    if (key_states[SDL.Scancode.A]) {
        player.position.x -= f32(player.speed)
        player.rect.x =  player.position.x
    }
    if (key_states[SDL.Scancode.D]) {
        player.position.x += f32(player.speed)
        player.rect.x =  player.position.x
    }
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
    ball.rect.x = SCREEN_WIDTH / 2 - (player.rect.w / 2 - 45)
    ball.rect.y = SCREEN_HEIGHT - (player.rect.h + 20)

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

            update(player)
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

    if !initialize(&game, &player) do return
    main_loop(&game, &player, &ball)

    SDL.DestroyRenderer(game.renderer)
    SDL.DestroyWindow(game.window)
    SDL.Quit()
}