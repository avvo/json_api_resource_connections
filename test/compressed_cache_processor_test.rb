require 'test_helper'

class CompressedCacheProcessorTest < Minitest::Test

  def setup
    @timestamp = Time.now
    @result_block_with_ids = [{ "id" => 1,
                              "name" => "jon",
                        "profesison" => "photographer",
                        "updated_at" => @timestamp},
                              
                              { "id" => 2,
                              "name" => "daniel",
                        "profesison" => "climber",
                        "updated_at" => @timestamp}]

    @result_block_without_ids = [{"name" => "Paint it Black",
                                  "type" => "boulder",
                                 "grade" => "v14"},

                                { "name" => "Jumbo Love",
                                  "type" => "sport climb",
                                 "grade" => "5.15b/c"}]

    @proc  = JsonApiResource::CacheProcessor::CompressedCacheProcessor
    @cache = @proc.cache
  end

  def test_write_splits_results_with_ids_into_blocks
    @proc.write( @result_block_with_ids, User, :where, {id: [1,2]})
    assert_equal [1, 2], @cache.read("user/where/[{:id=>[1, 2]}]")
  end

  def test_split_data_writes_do_not_duplicate_individual_data_entries
    @proc.write( @result_block_with_ids, User, :where, {id: [1,2]})
    @proc.write( @result_block_with_ids, User, :where, {per_page: 10})

    assert_equal [1, 2], @cache.read("user/where/[{:id=>[1, 2]}]")
    assert_equal [1, 2], @cache.read("user/where/[{:per_page=>10}]")

    assert_equal( { "id" => 1,
                  "name" => "jon",
            "profesison" => "photographer",
            "updated_at" => @timestamp }, @cache.read("user/where/id:1"))
  end

  def test_writes_non_idd_results_wholesale
    @proc.write(@result_block_without_ids, Climb, :where, {id: [1,2]} )
    assert_equal @result_block_without_ids, @cache.read("climb/where/[{:id=>[1, 2]}]")
  end

  def test_read_reassembles_split_data
    @proc.write( @result_block_with_ids, User, :where, {id: [1,2]})
    @proc.write( @result_block_with_ids, User, :where, {per_page: 10})

    assert_equal @result_block_with_ids, @proc.read(User, :where, {id: [1,2]})
    assert_equal @result_block_with_ids, @proc.read(User, :where, {per_page: 10})
  end

  def test_read_unsplitable_data_returns_undamaged_data
    @proc.write( @result_block_without_ids, Climb, :where, {id: [1,2]} )
    @proc.write( @result_block_without_ids, Climb, :where, {per_page: 10} )

    assert_equal @result_block_without_ids, @proc.read(Climb, :where, {id: [1,2]})
    assert_equal @result_block_without_ids, @proc.read(Climb, :where, {per_page: 10})
  end

end