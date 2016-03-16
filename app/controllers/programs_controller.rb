class ProgramsController < ApplicationController
  def search
    @programs = Program.search(params[:search_word])
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def program_params
    params.require(:program).permit(:search_word)
  end
end
