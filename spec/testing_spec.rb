# encoding: utf-8

require 'spec_helper'

HTML_BASE = <<-CODE
<!DOCTYPE html>
<html>
<body>
  <b><a href="http://foo.com/"">foo</a></b>
  <img src="http://foo.com/bar.jpg">
</body>
</html>
CODE

HTML_ADD_ATTRIBUTES      = '<a href="http://foo.com" rel="nofollow">foo</a>'
HTML_ATTRIBUTES          = '<a id="brand" class="external" href="http://foo.com" rel="nofollow" title="test title">foo</a>'
HTML_ALLOW_COMMENTS      = '<!-- Sample allowed comment --><b>foo</b>'
HTML_ELEMENTS            = '<span>foo</span>'
HTML_OUTPUT              = 'one<br/>two'
HTML_OUTPUT_ENCODING     = 'Caña de picaña'
HTML_PROTOCOLS           = '<a id="brand" href="ftp://foo.com">foo</a>'
HTML_REMOVE_CONTENTS     = 'Title<span>subtitle</span>'
HTML_WHITESPACE_ELEMENTS = 'Super<span>amazing</span>'
HTML_TRANSFORMERS        = '<h2>Can be transformed</h2>'

describe 'Sanitize' do
  context 'without any configuration option' do
    let(:base) { Sanitize.clean(HTML_BASE) }

    it 'filters all data' do
      expect(base.strip).to eq 'foo'
    end
  end

  context 'adds a restricted configuration built-in mode' do
    let(:restricted) { Sanitize.clean(HTML_BASE, Sanitize::Config::RESTRICTED) }
    let(:response)   { '<b>foo</b>' }

    it 'filters data' do
      expect(restricted.strip).to eq response
    end
  end

  context 'adds a base configuration built-in mode' do
    let(:basic)    { Sanitize.clean(HTML_BASE, Sanitize::Config::BASIC) }
    let(:response) { '<b><a href="http://foo.com/" rel="nofollow">foo</a></b>' }

    it 'filters data' do
      expect(basic.strip).to eq response
    end
  end

  context 'adds a relazed configuration built-in mode' do
    let(:relaxed)  { Sanitize.clean(HTML_BASE, Sanitize::Config::RELAXED) }
    let(:response) { '<b><a href="http://foo.com/">foo</a></b>  <img src="http://foo.com/bar.jpg">' }

    it 'filters data' do
      expect(relaxed.strip.delete("\n")).to eq response
    end
  end

  context 'given custom configuration' do
    let(:config) {
      { elements:   %w(a b),
        attributes: { 'a' => %w(id href), 'b' => %w(class id) },
        protocols:  { 'a' => { 'href' => ['http'] }}} }

    context 'admits a hash of options' do
      let(:response) { '<b><a href="http://foo.com/">foo</a></b>' }

      it 'maintains spaces' do
        expect(Sanitize.clean(HTML_BASE, config).strip).to eq response
      end
    end

    context ':add_attributes' do
      before :each do
        config[:add_attributes] = { 'a' => { 'rel' => 'nofollow' } }
      end

      let(:response) { '<a href="http://foo.com" rel="nofollow">foo</a>' }

      it 'filters data' do
        expect(Sanitize.clean(HTML_ADD_ATTRIBUTES, config).strip).to eq response
      end
    end

    context ':attributes' do
      before :each do
        config[:attributes] = { :all => ['class'], 'a' => ['href'] }
      end

      let(:response) { '<a class="external" href="http://foo.com">foo</a>' }

      it 'filters data and supports some attributes on all elements' do
        expect(Sanitize.clean(HTML_ATTRIBUTES, config).strip).to eq response
      end
    end

    context ':allow_comments' do
      before :each do
        config[:allow_comments] = true
      end

      let(:response) { HTML_ALLOW_COMMENTS }

      it 'can do it but it is discouraged' do
        expect(Sanitize.clean(HTML_ALLOW_COMMENTS, config).strip).to eq response
      end
    end

    context ':elements' do
      let(:response) { 'foo' }

      it 'is used to maintain a whitelist of elements' do
        expect(Sanitize.clean(HTML_ELEMENTS, config)).to eq response
      end
    end

    context ':output' do
      before :each do
        config[:elements] = %w(br)
        config[:output]   = :html
      end

      let(:response) { 'one<br>two' }

      it 'can be :html or :xhtml' do
        expect(Sanitize.clean(HTML_OUTPUT, config)).to eq response
      end
    end

    context ':output_encoding' do
      before :each do
        config[:output_encoding] = 'ASCII'
      end

      let(:response) { 'Ca&#241;a de pica&#241;a' }

      it 'is used to maintain a whitelist of elements' do
        expect(Sanitize.clean(HTML_OUTPUT_ENCODING, config)).to eq response
      end
    end

    context ':protocols' do
      let(:response) { '<a id="brand">foo</a>' }

      it 'accepts url http protocols' do
        expect(Sanitize.clean(HTML_PROTOCOLS, config)).to eq response
      end
    end

    context ':remove_contents' do
      before :each do
        config[:remove_contents] = true
      end

      let(:response) { 'Title' }

      it 'removes the content of any non-whitelisted elements in addition to elements themselves' do
        expect(Sanitize.clean(HTML_REMOVE_CONTENTS, config)).to eq response
      end

      it 'does not removes the content of any non-whitelisted elements in addition to elements themselves' do
        expect(Sanitize.clean(HTML_REMOVE_CONTENTS, removes_content: false)).to eq 'Titlesubtitle'
      end
    end

    context ':whitespace_elements' do
      before :each do
        config[:whitespace_elements] = %w(span)
      end

      let(:response) { 'Super amazing ' }

      it 'adds whitespaces to removed tags' do
        expect(Sanitize.clean(HTML_WHITESPACE_ELEMENTS, config)).to eq response
      end
    end

    context ':transformers' do
      let(:transformer) { ->(env) { { node_whitelist: [env[:node]] } if env[:node_name] == 'h2' }}
      let(:response) { HTML_TRANSFORMERS }

      it 'can handle external domain logic' do
        expect(Sanitize.clean(HTML_TRANSFORMERS, :transformers => transformer)).to eq response
      end
    end
  end
end
