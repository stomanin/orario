require File.dirname(__FILE__) + '/../test_helper'
require 'utente_controller'

# Re-raise errors caught by the controller.
class UtenteController; def rescue_action(e) raise e end; end

class UtenteControllerTest < Test::Unit::TestCase
  def setup
    @controller = UtenteController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
