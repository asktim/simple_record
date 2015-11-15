require 'spec_helper'

describe 'Sample Usage' do
  let(:db) { ENV['simple_record_db'] || 'simple_record' }

  before { SimpleRecord.connection = PG.connect(dbname: db) }

  describe 'simple_record/schema' do
    class Article
      include Schema

      # Schema Definition
      attribute 'name', :string
      attribute 'description', :text
      attribute 'read_count', :integer
    end

    class Comment
      include Schema

      attribute 'text', :text
    end

    context 'New Record' do
      let(:attributes) { {} }

      subject { Article.new(attributes) }

      it 'should respond to schema described methods' do
        is_expected.to respond_to(:name)
        is_expected.to respond_to(:description)
        is_expected.to respond_to(:read_count)
        is_expected.not_to respond_to(:text)
      end

      context 'with init attributes' do
        let(:attributes) { { 'name' => 'Mythbusters are gone', 'blah' => '' } }

        it 'should populate initialization values' do
          expect(subject.name).to eql('Mythbusters are gone')
          expect{ subject.blah }.to raise_error(NoMethodError)
        end
      end
    end
  end
end
