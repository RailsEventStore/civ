require 'test_helper'

class PitbossEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pitboss_entry = pitboss_entries(:one)
  end

  test "should get index" do
    get pitboss_entries_url
    assert_response :success
  end

  test "should get new" do
    get new_pitboss_entry_url
    assert_response :success
  end

  test "should create pitboss_entry" do
    assert_difference('PitbossEntry.count') do
      post pitboss_entries_url, params: { pitboss_entry: { entry_type: @pitboss_entry.entry_type, game_name: @pitboss_entry.game_name, player_name: @pitboss_entry.player_name, timestamp: @pitboss_entry.timestamp } }
    end

    assert_redirected_to pitboss_entry_url(PitbossEntry.last)
  end

  test "should show pitboss_entry" do
    get pitboss_entry_url(@pitboss_entry)
    assert_response :success
  end

  test "should get edit" do
    get edit_pitboss_entry_url(@pitboss_entry)
    assert_response :success
  end

  test "should update pitboss_entry" do
    patch pitboss_entry_url(@pitboss_entry), params: { pitboss_entry: { entry_type: @pitboss_entry.entry_type, game_name: @pitboss_entry.game_name, player_name: @pitboss_entry.player_name, timestamp: @pitboss_entry.timestamp } }
    assert_redirected_to pitboss_entry_url(@pitboss_entry)
  end

  test "should destroy pitboss_entry" do
    assert_difference('PitbossEntry.count', -1) do
      delete pitboss_entry_url(@pitboss_entry)
    end

    assert_redirected_to pitboss_entries_url
  end
end
