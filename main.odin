package main

import "core:fmt"
import "core:log"
import SDL "vendor:sdl3"

Game :: struct {
    window: ^SDL.Window,
    renderer: ^SDL.Renderer,
    event: SDL.Event,

    player: SDL.FRect,
    block: SDL.FRect,
}

SCREEN_WIDTH :: 1280
SCREEN_HEIGHT :: 720

initialize :: proc(game: ^Game) -> bool {
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

    return true
}

player :: proc(game: ^Game) {
    game.player.w = 100
    game.player.h = 10
    game.player.x = SCREEN_WIDTH / 2 - game.player.w / 2
    game.player.y = SCREEN_HEIGHT - (game.player.h + 5)

    SDL.SetRenderDrawColor(game.renderer, 255, 255, 255, 255)
    SDL.RenderFillRect(game.renderer, &game.player)
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

main_loop :: proc(game: ^Game) {
    for {
        for SDL.PollEvent(&game.event) {
            #partial switch game.event.type {
                case .QUIT:
                    return
                }
            }
            SDL.SetRenderDrawColor(game.renderer, 0, 0, 0, 255)
            SDL.RenderClear(game.renderer)

            player(game)
            render_blocks(game)

            SDL.RenderPresent(game.renderer)
    }
}

main :: proc() {
    fmt.printf("hello world")

    game: Game

    if !initialize(&game) do return
    main_loop(&game)

    SDL.DestroyRenderer(game.renderer)
    SDL.DestroyWindow(game.window)
    SDL.Quit()
}