require "helper"

module Nokogiri
  module XML
    class TestBuilder < Nokogiri::TestCase
      def test_root_namespace_default_decl
        b = Nokogiri::XML::Builder.new { |xml| xml.root(:xmlns => 'one:two') }
        doc = b.doc
        assert_equal 'one:two', doc.root.namespace.href
        assert_equal({ 'xmlns' => 'one:two' }, doc.root.namespaces)
      end

      def test_root_namespace_multi_decl
        b = Nokogiri::XML::Builder.new { |xml|
          xml.root(:xmlns => 'one:two', 'xmlns:foo' => 'bar') do
            xml.hello
          end
        }
        doc = b.doc
        assert_equal 'one:two', doc.root.namespace.href
        assert_equal({ 'xmlns' => 'one:two', 'xmlns:foo' => 'bar' }, doc.root.namespaces)

        assert_equal 'one:two', doc.at('hello').namespace.href
      end

      def test_non_root_namespace
        b = Nokogiri::XML::Builder.new { |xml|
          xml.root { xml.hello(:xmlns => 'one') }
        }
        assert_equal 'one', b.doc.at('hello', 'xmlns' => 'one').namespace.href
      end

      def test_specify_namespace
        b = Nokogiri::XML::Builder.new { |xml|
          xml.root('xmlns:foo' => 'bar') do
            xml[:foo].bar
            xml['foo'].baz
          end
        }
        doc = b.doc
        assert_equal 'bar', b.doc.at('foo|bar', 'foo' => 'bar').namespace.href
        assert_equal 'bar', b.doc.at('foo|baz', 'foo' => 'bar').namespace.href
      end

      def test_specify_namespace_nested
        b = Nokogiri::XML::Builder.new { |xml|
          xml.root('xmlns:foo' => 'bar') do
            xml.yay do
              xml[:foo].bar

              xml.yikes do
                xml['foo'].baz
              end
            end
          end
        }
        doc = b.doc
        assert_equal 'bar', b.doc.at('foo|bar', 'foo' => 'bar').namespace.href
        assert_equal 'bar', b.doc.at('foo|baz', 'foo' => 'bar').namespace.href
      end

      def test_specified_namespace_undeclared
        b = Nokogiri::XML::Builder.new { |xml|
          xml.root do
            assert_raises(ArgumentError) do
              xml[:foo]
            end
          end
        }
      end

      def test_set_encoding
        builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
          xml.root do
            xml.bar 'blah'
          end
        end
        assert_match 'UTF-8', builder.to_xml
      end

      def test_bang_and_underscore_is_escaped
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.root do
            xml.p_('adsfadsf')
            xml.p!('adsfadsf')
          end
        end
        assert_equal 2, builder.doc.xpath('//p').length
      end

      def test_square_brackets_set_attributes
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.root do
            foo = xml.foo
            foo['id'] = 'hello'
            assert_equal 'hello', foo['id']
          end
        end
        assert_equal 1, builder.doc.xpath('//foo[@id = "hello"]').length
      end

      def test_nested_local_variable
        @ivar     = 'hello'
        local_var = 'hello world'
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.root do
            xml.foo local_var
            xml.bar @ivar
            xml.baz {
              xml.text @ivar
            }
          end
        end

        assert_equal 'hello world', builder.doc.at('//root/foo').content
        assert_equal 'hello', builder.doc.at('//root/bar').content
        assert_equal 'hello', builder.doc.at('baz').content
      end

      def test_raw_append
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.root do
            xml << 'hello'
          end
        end

        assert_equal 'hello', builder.doc.at('/root').content
      end

      def test_raw_append_with_instance_eval
        builder = Nokogiri::XML::Builder.new do
          root do
            self << 'hello'
          end
        end

        assert_equal 'hello', builder.doc.at('/root').content
      end

      def test_cdata
        builder = Nokogiri::XML::Builder.new do
          root {
            cdata "hello world"
          }
        end
        assert_equal("<?xml version=\"1.0\"?><root><![CDATA[hello world]]></root>", builder.to_xml.gsub(/\n/, ''))
      end

      def test_builder_no_block
        string = "hello world"
        builder = Nokogiri::XML::Builder.new
        builder.root {
          cdata string
        }
        assert_equal("<?xml version=\"1.0\"?><root><![CDATA[hello world]]></root>", builder.to_xml.gsub(/\n/, ''))
      end
    end
  end
end
