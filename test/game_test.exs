defmodule GameTest do
  use ExUnit.Case

  alias Hangman.Game

  test "new_game returns structure" do
    game = Game.new_game()
    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
    assert Enum.all?(game.letters, fn(x) -> x =~ ~r/[a-z]/ end)
  end

  test "state isn't changed for :won or :lost game" do
    for state <- [ :won, :lost ] do
      game = Game.new_game() |> Map.put(:game_state, state)
      assert ^game = Game.make_move(game, "x")
    end
  end

  test "first occurence of letter is not already used" do
    game = Game.new_game()
    game = Game.make_move(game, "f")
    assert(game.game_state != :already_used)
  end

  test "second occurence of letter is already used" do
    game = Game.new_game()
    game = Game.make_move(game, "f")
    assert(game.game_state != :already_used)
    game = Game.make_move(game, "f")
    assert(game.game_state == :already_used)
  end

  test "a good guess is recognized" do
    game = Game.new_game("brumbo")
    game = Game.make_move(game, "b")
    assert(game.game_state == :good_guess)
    assert(game.turns_left == 7)
  end

  test "a guessed word is a won game" do
    moves = [
      {"b", :good_guess},
      {"r", :good_guess},
      {"u", :good_guess},
      {"m", :good_guess},
      {"o", :won},
    ]
    game = Game.new_game("brumbo")
    Enum.reduce(moves, game, fn({guess, state}, game) ->
      game = Game.make_move(game, guess)
      assert(game.game_state == state)
      game
    end)
  end

  test "a bad guess is recognized" do
    game = Game.new_game("brumbo")
    game = Game.make_move(game, "x")
    assert(game.game_state == :bad_guess)
    assert(game.turns_left == 6)
  end

  test "a game can be lost" do
    moves = [
      {"a", :bad_guess, 6},
      {"b", :bad_guess, 5},
      {"c", :bad_guess, 4},
      {"d", :bad_guess, 3},
      {"e", :bad_guess, 2},
      {"f", :bad_guess, 1},
      {"g", :lost, 0},
    ]
    game = Game.new_game("x")
    Enum.reduce(moves, game, fn({guess, state, turns_left}, game) ->
      game = Game.make_move(game, guess)
      assert(game.turns_left == turns_left)
      assert(game.game_state == state)
      game
    end)
  end
end
