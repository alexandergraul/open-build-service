require File.expand_path(File.dirname(__FILE__) + "/..") + "/test_helper"

class IssueControllerTest < ActionController::IntegrationTest
  def test_get_issues
    # get full issue
    get '/issue_trackers/bnc/issues/123456'
    assert_response :success
    assert_tag :tag => 'name', :content => "123456"
    assert_tag :tag => 'issue_tracker', :content => "bnc"
    assert_tag :tag => 'long_name', :content => "bnc#123456"
    assert_tag :tag => 'url', :content => "https://bugzilla.novell.com/show_bug.cgi?id=123456"
    assert_tag :tag => 'state', :content => "RESOLVED"
    assert_tag :tag => 'description', :content => "OBS is not bugfree!"
    assert_tag :parent => { :tag => 'owner' }, :tag => 'login', :content => "fred"
    assert_tag :parent => { :tag => 'owner' }, :tag => 'email', :content => "fred@feuerstein.de"
    assert_tag :parent => { :tag => 'owner' }, :tag => 'realname', :content => "Frederic Feuerstone"
    assert_no_tag :tag => 'password'

    # get new, incomplete issue .. don't crash ...
    get '/issue_trackers/bnc/issues/1234'
    assert_response :success
    assert_tag :tag => 'name', :content => "1234"
    assert_tag :tag => 'issue_tracker', :content => "bnc"
    assert_no_tag :tag => 'password'
  end

  def test_search_issues
    ActionController::IntegrationTest::reset_auth
    get "/search/package_id", :match => 'patchinfo/issue/@name="123456"'
    assert_response 401
    get "/search/package_id", :match => 'patchinfo/issue/@issue_tracker="bnc"'
    assert_response 401
    get "/search/package_id", :match => '[patchinfo/issue/@name="123456" and patchinfo/issue/@issue_tracker="bnc"]'
    assert_response 401
    get "/search/package_id", :match => 'patchinfo/issue/owner/@login="fred"'
    assert_response 401

    # search via bug owner
    prepare_request_with_user "Iggy", "asdfasdf"
    get "/search/package_id", :match => 'patchinfo/issue/owner/@login="fred"'
    assert_response :success
    assert_tag :parent => { :tag => "collection" }, :tag => "package", :attributes => { :project => 'Devel:BaseDistro:Update', :name => 'pack3' }

    # search via bug issue id
    # FIXME: This would be more elegant but is currently not supported by our api xpath parser
    #get "/search/package_id", :match => 'patchinfo/issue/[@name="123456" and @issue_tracker="bnc"]'
    get "/search/package_id", :match => '[patchinfo/issue/@name="123456" and patchinfo/issue/@issue_tracker="bnc"]'
    assert_response :success
    assert_tag :parent => { :tag => "collection" }, :tag => "package", :attributes => { :project => 'Devel:BaseDistro:Update', :name => 'pack3' }

  end
end
