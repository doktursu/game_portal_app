class TttLogic
  
  DEFAULT_BOARD = [nil, nil, nil,
                   nil, nil, nil, 
                   nil, nil, nil]

  def initialize(game, win_checker)
    @game = game
    @board = game.board
    @win_checker = win_checker
  end

  ################ FROM TTTGAME ################

  def turn(move)
    unless game_finished?
      if valid_move?(move)
        update_board(move)
        check_for_win(move)
      end
    end
    return @game
  end

  ################ METHODS ################

  def game_finished?
    @game.state == "finished"
  end

  def valid_move?(move)
    if out_of_range?(move.square)
      @game.update(state: 'in_progress', message: "Move not valid. Pick again.")
      @game.ttt_moves.destroy(move)
      return false
    end
    if space_filled?(move.square)
      @game.update(state: 'in_progress', message: "Space #{move.square} already filled. Pick again")
      @game.ttt_moves.destroy(move)
      return false
    end
    return true
  end

  def update_board(move)
    @board[move.square] = move.player[:symbol]
    @game.board = @board
  end

  def check_for_win(move)
    if @win_checker.has_won?(move.player[:symbol], @board)
      case @game.opponent
        when 'user', 'ai'
          @game.update(winner_id: @game.current_player[:id])
          @game.update(state: 'finished', message: "#{@game.winner_user.username} Wins!")
        when 'friend'
          @game.update(state: 'finished', message: "#{@game.current_player[:symbol].to_s} Wins!")
        # else
          # @game.update(winner_id: @game.current_player[:id])
          # @game.update(state: 'finished', message: "#{@game.winner_user.username} Wins!")
      end
    elsif board_full?
      @game.update(state: 'finished', is_draw: true, message: "Game is a draw")
    else
      update_current_player
      @game.update(state: 'in_progress', message: nil)
    end
  end

  def update_current_player
    @game.current_player = case @game.current_player
                             when @game.player1 then @game.player2
                             when @game.player2 then @game.player1
                           end
    # @game.current_player = [@game.player1, @game.player2].reject { |player| player == @game.current_player }.first

    @game.save
  end

  # def reset
  #   @board = DEFUALT_BOARD
  #   @turn = 0
  #   @pieces.rotate!
  #   display_board()
  # end

  ################ PRIVATE METHODS ################

  private

    def out_of_range?(square)
      square > 8 || square < 0
    end

    def space_filled?(square)
      @board[square]
    end

    def board_full?
      @board.all?
    end
  
end