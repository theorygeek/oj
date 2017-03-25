#frozen_string_literal: false
require 'json_gem/test_helper'
require 'stringio'
require 'tempfile'

class JSONCommonInterfaceTest < Test::Unit::TestCase
  include Test::Unit::TestCaseOmissionSupport
  include Test::Unit::TestCasePendingSupport

  def setup
    @hash = {
      'a' => 2,
      'b' => 3.141,
      'c' => 'c',
      'd' => [ 1, "b", 3.14 ],
      'e' => { 'foo' => 'bar' },
      'g' => "\"\0\037",
      'h' => 1000.0,
      'i' => 0.001
    }
    @json = '{"a":2,"b":3.141,"c":"c","d":[1,"b",3.14],"e":{"foo":"bar"},'\
      '"g":"\\"\\u0000\\u001f","h":1000.0,"i":0.001}'
  end

  def test_index
    omit_if(MIMIC_JSON, "mimic_JSON")
    assert_equal @json, JSON[@hash]
    assert_equal @hash, JSON[@json]
  end

  def test_parser
    omit_if(MIMIC_JSON, "mimic_JSON")
    assert_match /::Parser\z/, JSON.parser.name
  end

  def test_generator
    omit_if(MIMIC_JSON, "mimic_JSON")
    assert_match /::Generator\z/, JSON.generator.name
  end

  def test_state
    omit_if(MIMIC_JSON, "mimic_JSON")
    assert_match /::Generator::State\z/, JSON.state.name
  end

  def test_create_id
    assert_equal 'json_class', JSON.create_id
    JSON.create_id = 'foo_bar'
    assert_equal 'foo_bar', JSON.create_id
  ensure
    JSON.create_id = 'json_class'
  end

  def test_deep_const_get
    pend("mimic_JSON") if MIMIC_JSON
    assert_raise(ArgumentError) { JSON.deep_const_get('Nix::Da') }
    assert_equal File::SEPARATOR, JSON.deep_const_get('File::SEPARATOR')
  end

  def test_parse
    assert_equal [ 1, 2, 3, ], JSON.parse('[ 1, 2, 3 ]')
  end

  def test_parse_bang
    pend("mimic_JSON") if MIMIC_JSON
    assert_equal [ 1, NaN, 3, ], JSON.parse!('[ 1, NaN, 3 ]')
  end

  def test_generate
    pend("mimic_JSON") if MIMIC_JSON
    assert_equal '[1,2,3]', JSON.generate([ 1, 2, 3 ])
  end

  def test_fast_generate
    pend("mimic_JSON") if MIMIC_JSON
    assert_equal '[1,2,3]', JSON.generate([ 1, 2, 3 ])
  end

  def test_pretty_generate
    omit_if(MIMIC_JSON, "mimic_JSON")
    assert_equal "[\n  1,\n  2,\n  3\n]", JSON.pretty_generate([ 1, 2, 3 ])
  end

  def test_load
    assert_equal @hash, JSON.load(@json)
    tempfile = Tempfile.open('@json')
    tempfile.write @json
    tempfile.rewind
    assert_equal @hash, JSON.load(tempfile)
    stringio = StringIO.new(@json)
    stringio.rewind
    assert_equal @hash, JSON.load(stringio)
    assert_equal nil, JSON.load(nil)
    assert_equal nil, JSON.load('')
  ensure
    tempfile.close!
  end

  def test_load_with_options
    json  = '{ "foo": NaN }'
    assert JSON.load(json, nil, :allow_nan => true)['foo'].nan?
  end

  def test_load_null
    pend("mimic_JSON") if MIMIC_JSON
    assert_equal nil, JSON.load(nil, nil, :allow_blank => true)
    assert_raise(TypeError) { JSON.load(nil, nil, :allow_blank => false) }
    assert_raise(JSON::ParserError) { JSON.load('', nil, :allow_blank => false) }
  end

  def test_dump
    pend("mimic_JSON") if MIMIC_JSON
    too_deep = '[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]'
    assert_equal too_deep, JSON.dump(eval(too_deep))
    assert_kind_of String, Marshal.dump(eval(too_deep))
    assert_raise(ArgumentError) { JSON.dump(eval(too_deep), 100) }
    assert_raise(ArgumentError) { Marshal.dump(eval(too_deep), 100) }
    assert_equal too_deep, JSON.dump(eval(too_deep), 101)
    assert_kind_of String, Marshal.dump(eval(too_deep), 101)
    output = StringIO.new
    JSON.dump(eval(too_deep), output)
    assert_equal too_deep, output.string
    output = StringIO.new
    JSON.dump(eval(too_deep), output, 101)
    assert_equal too_deep, output.string
  end

  def test_dump_should_modify_defaults
    max_nesting = JSON.dump_default_options[:max_nesting]
    JSON.dump([], StringIO.new, 10)
    assert_equal max_nesting, JSON.dump_default_options[:max_nesting]
  end

  def test_JSON
    omit_if(MIMIC_JSON, "mimic_JSON")
    assert_equal @json, JSON(@hash)
    assert_equal @hash, JSON(@json)
  end
end
