require 'test_helper'

class CompressedCacheProcessorTest < Minitest::Test

  def setup
    @timestamp = Time.now
      @result_block_with_ids = JsonApiClient::ResultSet.new(
                    [User.new({ "id" => 1,
                              "name" => "jon",
                        "profesison" => "photographer",
                        "updated_at" => @timestamp}),
                              
                     User.new({ "id" => 2,
                              "name" => "daniel",
                        "profesison" => "climber",
                        "updated_at" => @timestamp})])

    @result_block_without_ids = JsonApiClient::ResultSet.new(
                      [Climb.new({"name" => "Paint it Black",
                                  "type" => "boulder",
                                 "grade" => "v14"}),

                      Climb.new({ "name" => "Jumbo Love",
                                  "type" => "sport climb",
                                 "grade" => "5.15b/c"})])

    @proc  = JsonApiResource::CacheProcessor::CompressedCacheProcessor
    @cache = @proc.cache
  end

  def test_write_splits_results_with_ids_into_blocks
    @proc.write( @result_block_with_ids, User, :where, {id: [1,2]})
    assert_equal [1, 2], @cache.fetch("connection::#{JsonApiResourceConnections::VERSION}/user/where/[{:id=>[1, 2]}]")
  end

  def test_split_data_writes_do_not_duplicate_individual_data_entries
    @proc.write( @result_block_with_ids, User, :where, {id: [1,2]})
    @proc.write( @result_block_with_ids, User, :where, {per_page: 10})

    assert_equal [1, 2], @cache.fetch("connection::#{JsonApiResourceConnections::VERSION}/user/where/[{:id=>[1, 2]}]")
    assert_equal [1, 2], @cache.fetch("connection::#{JsonApiResourceConnections::VERSION}/user/where/[{:per_page=>10}]")

    assert_equal( { "id" => 1,
                  "name" => "jon",
            "profesison" => "photographer",
            "updated_at" => @timestamp }, @cache.fetch("connection::#{JsonApiResourceConnections::VERSION}/user/where/id:1"))
  end

  def test_writes_non_idd_results_wholesale
    @proc.write( @result_block_without_ids, Climb, :where, {id: [1,2]} )
    assert_equal @result_block_without_ids.map(&:attributes), @cache.fetch("connection::#{JsonApiResourceConnections::VERSION}/climb/where/[{:id=>[1, 2]}]")
  end

  def test_fetch_reassembles_split_data
    @proc.write( @result_block_with_ids, User, :where, {id: [1,2]})
    @proc.write( @result_block_with_ids, User, :where, {per_page: 10})

    assert_equal @result_block_with_ids, @proc.fetch(User, :where, {id: [1,2]})
    assert_equal @result_block_with_ids, @proc.fetch(User, :where, {per_page: 10})
  end

  def test_fetch_unsplitable_data_returns_undamaged_data
    @proc.write( @result_block_without_ids, Climb, :where, {id: [1,2]} )
    @proc.write( @result_block_without_ids, Climb, :where, {per_page: 10} )

    assert_equal @result_block_without_ids, @proc.fetch(Climb, :where, {id: [1,2]})
    assert_equal @result_block_without_ids, @proc.fetch(Climb, :where, {per_page: 10})
  end

end