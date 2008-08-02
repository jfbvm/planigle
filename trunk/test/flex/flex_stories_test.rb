require "#{File.dirname(__FILE__)}/../test_helper"
require 'test/unit'
require 'funfx' 

class FlexStoriesTest < Test::Unit::TestCase
  fixtures :systems
  fixtures :individuals
  fixtures :projects
  fixtures :releases
  fixtures :iterations
  fixtures :stories
  fixtures :tasks

  def setup
    @ie = Funfx.instance 
    @ie.start(false) 
    @ie.speed = 1
    @ie.goto("http://localhost:3000/index.html", "Main") 
    sleep 1 # Wait to ensure remember me check is made
  end 
  
  def teardown
    @ie.unload
    Fixtures.reset_cache # Since we have a separate process changing the database
  end

  # Test create failure.
  def test_create_failure
    init('admin2')
    create_story_failure
  end 

  # Test create failure.
  def test_create_success
    init('admin2')
    create_story_success
  end 

  # Test create failure.
  def test_create_cancel
    init('admin2')
    create_story_cancel
  end 

  # Test edit failure.
  def test_an_edit_failure
    init('admin2')
    edit_story_failure
  end 

  # Test edit failure.
  def test_an_edit_success
    init('admin2')
    edit_story_success
  end 

  # Test edit failure.
  def test_an_edit_cancel
    init('admin2')
    edit_story_cancel
  end 

  # Test editing multiple.
  def test_an_edit_multiple
    init('admin2')
    edit_single
    edit_multiple
  end 

  # Test misc (in one stream for more efficiency).
  def test_misc
    init('admin2')
    delete_story_cancel
    delete_story
    sort_columns
  end

  # Test deleting multiple.
  def test_z_misc_delete_multiple
    init('admin2')
    delete_single
    delete_multiple
  end 

  # Test logging in as a project admin
  def test_project_admin
    init('aaron')
    assert @ie.button("storyBtnCreate").visible
    assert @ie.button("storyBtnEdit")[1].visible
    assert @ie.button("storyBtnDelete")[1].visible
  end

  # Test logging in as a project user
  def test_project_user
    init('user')
    assert @ie.button("storyBtnCreate").visible
    assert @ie.button("storyBtnEdit")[1].visible
    assert @ie.button("storyBtnDelete")[1].visible
  end

  # Test logging in as a read only user
  def test_read_only
    init('readonly')
    assert !@ie.button("storyBtnCreate").visible
    assert !@ie.button("storyBtnEdit")[1].visible
    assert !@ie.button("storyBtnDelete")[1].visible
  end

private

  # Test whether error handling works for creating a story.
  def create_story_failure
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnCreate").click
    
    assert_equal '', @ie.text_area("storyFieldName").text
    assert_equal '', @ie.text_area("storyFieldDescription").text
    assert_equal '', @ie.text_area("storyFieldAcceptanceCriteria").text
    assert_equal 'Backlog', @ie.combo_box("storyFieldIteration").text
    assert_equal 'No Release', @ie.combo_box("storyFieldRelease").text
    assert_equal 'No Owner', @ie.combo_box("storyFieldOwner").text
    assert_equal '', @ie.text_area("storyFieldEffort").text
    assert_equal 'Created', @ie.combo_box("storyFieldStatus").text
    assert_equal 'false', @ie.combo_box("storyFieldPublic").text

    create_story(' ', 'description', 'acceptance_criteria', 'fourth', 'second', 'ted williams', '1', 'Created', 'true')
    @ie.button("storyBtnChange").click

    # Values should not change
    assert_equal "Name can't be blank", @ie.text_area("storyError").text
    assert_equal ' ', @ie.text_area("storyFieldName").text
    assert_equal 'description', @ie.text_area("storyFieldDescription").text
    assert_equal 'acceptance_criteria', @ie.text_area("storyFieldAcceptanceCriteria").text
    assert_equal 'fourth', @ie.combo_box("storyFieldIteration").text
    assert_equal 'second', @ie.combo_box("storyFieldRelease").text
    assert_equal 'ted williams', @ie.combo_box("storyFieldOwner").text
    assert_equal '1', @ie.text_area("storyFieldEffort").text
    assert_equal 'Created', @ie.combo_box("storyFieldStatus").text
    assert_equal 'true', @ie.combo_box("storyFieldPublic").text
    assert_not_nil @ie.button("storyBtnCancel")
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnCancel").click
  end
    
  # Test whether you can successfully create a story.
  def create_story_success
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnCreate").click
    
    assert_equal '', @ie.text_area("storyFieldName").text
    assert_equal '', @ie.text_area("storyFieldDescription").text
    assert_equal '', @ie.text_area("storyFieldAcceptanceCriteria").text
    assert_equal 'Backlog', @ie.combo_box("storyFieldIteration").text
    assert_equal 'No Release', @ie.combo_box("storyFieldRelease").text
    assert_equal 'No Owner', @ie.combo_box("storyFieldOwner").text
    assert_equal '', @ie.text_area("storyFieldEffort").text
    assert_equal 'Created', @ie.combo_box("storyFieldStatus").text
    assert_equal 'false', @ie.combo_box("storyFieldPublic").text
    
    create_story('foo', 'description', 'acceptance_criteria', 'fourth', 'second', 'ted williams', '1', 'Created', 'true')
    @ie.button("storyBtnChange").click

    assert_equal 'Story was successfully created.', @ie.text_area("storyError").text
    assert_equal '', @ie.text_area("storyFieldName").text
    assert_equal '', @ie.text_area("storyFieldDescription").text
    assert_equal '', @ie.text_area("storyFieldAcceptanceCriteria").text
    assert_equal 'Backlog', @ie.combo_box("storyFieldIteration").text
    assert_equal 'No Release', @ie.combo_box("storyFieldRelease").text
    assert_equal 'No Owner', @ie.combo_box("storyFieldOwner").text
    assert_equal '', @ie.text_area("storyFieldEffort").text
    assert_equal 'Created', @ie.combo_box("storyFieldStatus").text
    assert_equal 'false', @ie.combo_box("storyFieldPublic").text
    assert_not_nil @ie.button("storyBtnCancel")
    assert_equal num_rows + 1, @ie.data_grid("storyResourceGrid").num_rows
    assert_equal ",foo,fourth,ted williams,1.0,Created,true,4,,Edit | Delete | Add Task | Split", @ie.data_grid("storyResourceGrid").tabular_data(:start => num_rows, :end => num_rows)
    @ie.button("storyBtnCancel").click
  end
    
  # Test whether you can successfully cancel creation of a story.
  def create_story_cancel
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnCreate").click
    create_story('foo', 'description', 'acceptance_criteria', 'fourth', 'second', 'ted williams', '1', 'Created', 'true')
    @ie.button("storyBtnCancel").click
    assert_equal '', @ie.text_area("storyError").text
    assert_nil @ie.button("storyBtnCancel")
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
  end

  # Create a story.
  def create_story(name, description, acceptance_criteria, iteration, release, owner, effort, status, public)
    @ie.text_area("storyFieldName").input(:text => name )
    @ie.text_area("storyFieldDescription").input(:text => description )
    @ie.text_area("storyFieldAcceptanceCriteria").input(:text => acceptance_criteria )
    @ie.combo_box("storyFieldIteration").open
    @ie.combo_box("storyFieldIteration").select(:item_renderer => iteration )
    @ie.combo_box("storyFieldRelease").open
    @ie.combo_box("storyFieldRelease").select(:item_renderer => release )
    @ie.combo_box("storyFieldOwner").open
    @ie.combo_box("storyFieldOwner").select(:item_renderer => owner )
    @ie.text_area("storyFieldEffort").input(:text => effort )
    @ie.combo_box("storyFieldStatus").open
    @ie.combo_box("storyFieldStatus").select(:item_renderer => status )
    @ie.combo_box("storyFieldPublic").open
    @ie.combo_box("storyFieldPublic").select(:item_renderer => public )
  end
    
  # Test whether error handling works for editing a story.
  def edit_story_failure
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    edit_story(' ', 'description', 'acceptance_criteria', 'fourth', 'second', 'ted williams', '1', 'Created', 'true')
    @ie.button("storyBtnChange").click
    assert_equal "Name can't be blank", @ie.text_area("storyError").text
    assert_equal ' ', @ie.text_area("storyFieldName").text
    assert_equal 'description', @ie.text_area("storyFieldDescription").text
    assert_equal 'acceptance_criteria', @ie.text_area("storyFieldAcceptanceCriteria").text
    assert_equal 'fourth', @ie.combo_box("storyFieldIteration").text
    assert_equal 'second', @ie.combo_box("storyFieldRelease").text
    assert_equal 'ted williams', @ie.combo_box("storyFieldOwner").text
    assert_equal '1', @ie.text_area("storyFieldEffort").text
    assert_equal 'Created', @ie.combo_box("storyFieldStatus").text
    assert_equal 'true', @ie.combo_box("storyFieldPublic").text
    assert_not_nil @ie.button("storyBtnCancel")
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnCancel").click
  end
    
  # Test whether you can successfully edit a story.
  def edit_story_success
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    edit_story('foo 1', 'description', 'acceptance_criteria', 'fourth', 'second', 'ted williams', '1', 'Created', 'true')
    @ie.button("storyBtnChange").click
    sleep 3 # Wait for results
    assert_equal '', @ie.text_area("storyError").text
    assert_nil @ie.button("storyBtnCancel")
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
    assert_equal ",foo 1,fourth,ted williams,1.0,Created,true,1,2.0,Edit | Delete | Add Task | Split", @ie.data_grid("storyResourceGrid").tabular_data(:start => 0, :end => 0)
  end
    
  # Test whether you can successfully cancel editing a story.
  def edit_story_cancel
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    edit_story('foo 1', 'description', 'acceptance_criteria', 'fourth', 'second', 'ted williams', '1', 'Created', 'true')
    @ie.button("storyBtnCancel").click
    assert_equal '', @ie.text_area("storyError").text
    assert_nil @ie.button("storyBtnCancel")
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
  end
  
  # Edit a single story through the button at the top.
  def edit_single
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.data_grid("storyResourceGrid").select(:item_renderer => "test")
    @ie.button("storyBtnUpdateMultiple").click
    @ie.button("storyBtnCancel").click
    assert_equal '', @ie.text_area("storyError").text
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
  end
  
  # Edit multiple stories through the button at the top.
  def edit_multiple
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.data_grid("storyResourceGrid").select(:item_renderer => "test")
    @ie.data_grid("storyResourceGrid").select(:item_renderer => "test3", :ctrl_key => "true")
    @ie.button("storyBtnUpdateMultiple").click
    assert_equal 'No Change', @ie.combo_box("updateFieldIteration").text
    assert_equal 'No Change', @ie.combo_box("updateFieldRelease").text
    assert_equal 'No Change', @ie.combo_box("updateFieldOwner").text
    assert_equal 'No Change', @ie.combo_box("updateFieldStatus").text
    assert_equal 'No Change', @ie.combo_box("updateFieldPublic").text
    @ie.combo_box("updateFieldIteration").open
    @ie.combo_box("updateFieldIteration").select(:item_renderer => 'fourth' )
    @ie.combo_box("updateFieldRelease").open
    @ie.combo_box("updateFieldRelease").select(:item_renderer => 'first' )
    @ie.combo_box("updateFieldOwner").open
    @ie.combo_box("updateFieldOwner").select(:item_renderer => 'aaron hank' )
    @ie.combo_box("updateFieldStatus").open
    @ie.combo_box("updateFieldStatus").select(:item_renderer => 'Created' )
    @ie.combo_box("updateFieldPublic").open
    @ie.combo_box("updateFieldPublic").select(:item_renderer => 'true' )
    @ie.button("updateBtnOk").click
    assert_equal '', @ie.text_area("storyError").text
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
    assert_equal "+,test,fourth,aaron hank,1.0,Created,true,2,2.0,Edit | Delete | Add Task | Split", @ie.data_grid("storyResourceGrid").tabular_data(:start => 1, :end => 1)
    assert_equal ",test3,fourth,aaron hank,1.0,Created,true,1,2.0,Edit | Delete | Add Task | Split", @ie.data_grid("storyResourceGrid").tabular_data(:start => 0, :end => 0)
  end

  # Edit a story.
  def edit_story(name, description, acceptance_criteria, iteration, release, owner, effort, status, public)
    @ie.button("storyBtnEdit")[1].click
    @ie.text_area("storyFieldName").input(:text => name )
    @ie.text_area("storyFieldDescription").input(:text => description )
    @ie.text_area("storyFieldAcceptanceCriteria").input(:text => acceptance_criteria )
    @ie.combo_box("storyFieldIteration").open
    @ie.combo_box("storyFieldIteration").select(:item_renderer => iteration )
    @ie.combo_box("storyFieldRelease").open
    @ie.combo_box("storyFieldRelease").select(:item_renderer => release )
    @ie.combo_box("storyFieldOwner").open
    @ie.combo_box("storyFieldOwner").select(:item_renderer => owner )
    @ie.text_area("storyFieldEffort").input(:text => effort )
    @ie.combo_box("storyFieldStatus").open
    @ie.combo_box("storyFieldStatus").select(:item_renderer => status )
    @ie.combo_box("storyFieldPublic").open
    @ie.combo_box("storyFieldPublic").select(:item_renderer => public )
  end
    
  # Test deleting a story.
  def delete_story_cancel
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnDelete")[1].click
    @ie.alert("Delete")[0].button("No").click
    assert_equal '', @ie.text_area("storyError").text
    assert_equal num_rows, @ie.data_grid("storyResourceGrid").num_rows
  end
    
  # Test deleting a story.
  def delete_story
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.button("storyBtnDelete")[1].click
    @ie.alert("Delete")[0].button("Yes").click
    assert_equal '', @ie.text_area("storyError").text
    assert_equal num_rows-1, @ie.data_grid("storyResourceGrid").num_rows
  end
  
  # Delte a single story through the button at the top.
  def delete_single
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.data_grid("storyResourceGrid").select(:item_renderer => "test")
    @ie.button("storyBtnDeleteMultiple").click
    @ie.alert("Delete")[0].button("Yes").click
    assert_equal '', @ie.text_area("storyError").text
    assert_equal num_rows-1, @ie.data_grid("storyResourceGrid").num_rows
  end
  
  # Delete multiple stories through the button at the top.
  def delete_multiple
    @ie.combo_box("storyStatus").select(:item_renderer => 'All Statuses' )
    num_rows = @ie.data_grid("storyResourceGrid").num_rows
    @ie.data_grid("storyResourceGrid").select(:item_renderer => "test2")
    @ie.data_grid("storyResourceGrid").select(:item_renderer => "test3", :ctrl_key => "true")
    @ie.button("storyBtnDeleteMultiple").click
    @ie.alert("Delete")[0].button("Yes").click
    assert_equal '', @ie.text_area("storyError").text
    assert_equal num_rows-2, @ie.data_grid("storyResourceGrid").num_rows
  end
    
  # Test sorting the various columns.
  def sort_columns
    (1..8).each do |i|
      @ie.data_grid("storyResourceGrid").header_click(:columnIndex => i.to_s)
      @ie.data_grid("storyResourceGrid").header_click(:columnIndex => i.to_s) # Sort both ways
    end
  end
      
  # Log in to the system with the specified credentials.
  def login( logon, password )
    @ie.text_area("userID").input(:text => logon )
    @ie.text_area("userPassword").input(:text => password )
    @ie.button("loginButton").click
  end
  
  # Initialize for a particular logon
  def init( logon )
    login(logon, 'testit')
    sleep 5 # Wait to ensure data loaded
    @ie.button_bar("mainNavigation").change(:related_object => "Stories")
    @ie.combo_box("release").open
    @ie.combo_box("release").select(:item_renderer => 'All Releases' )
  end
end