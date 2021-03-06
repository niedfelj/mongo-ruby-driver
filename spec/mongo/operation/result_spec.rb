require 'spec_helper'

describe Mongo::Operation::Result do

  let(:result) do
    described_class.new(reply)
  end

  let(:cursor_id) { 0 }
  let(:documents) { [] }
  let(:flags) { [] }
  let(:starting_from) { 0 }

  let(:reply) do
    Mongo::Protocol::Reply.new.tap do |reply|
      reply.instance_variable_set(:@flags, flags)
      reply.instance_variable_set(:@cursor_id, cursor_id)
      reply.instance_variable_set(:@starting_from, starting_from)
      reply.instance_variable_set(:@number_returned, documents.size)
      reply.instance_variable_set(:@documents, documents)
    end
  end

  describe '#acknowledged?' do

    context 'when the reply is for a read command' do

      let(:documents) do
        [{ 'ismaster' => true, 'ok' => 1.0 }]
      end

      it 'returns true' do
        expect(result).to be_acknowledged
      end
    end

    context 'when the reply is for a write command' do

      context 'when the command was acknowledged' do

        let(:documents) do
          [{ "ok" => 1, "n" => 2 }]
        end

        it 'returns true' do
          expect(result).to be_acknowledged
        end
      end

      context 'when the command was not acknowledged' do

        let(:reply) { nil }

        it 'returns false' do
          expect(result).to_not be_acknowledged
        end
      end
    end
  end

  describe '#cursor_id' do

    context 'when the reply exists' do

      let(:cursor_id) { 5 }

      it 'delegates to the reply' do
        expect(result.cursor_id).to eq(5)
      end
    end

    context 'when the reply does not exist' do

      let(:reply) { nil }

      it 'returns zero' do
        expect(result.cursor_id).to eq(0)
      end
    end
  end

  describe '#documents' do

    context 'when the result is for a command' do

      context 'when a reply is received' do

        let(:documents) do
          [{ "ok" => 1, "n" => 2 }]
        end

        it 'returns the documents' do
          expect(result.documents).to eq(documents)
        end
      end

      context 'when a reply is not received' do

        let(:reply) { nil }

        it 'returns an empty array' do
          expect(result.documents).to be_empty
        end
      end
    end
  end

  describe '#each' do

    let(:documents) do
      [{ "ok" => 1, "n" => 2 }]
    end

    context 'when a block is given' do

      it 'yields to each document' do
        result.each do |document|
          expect(document).to eq(documents.first)
        end
      end
    end

    context 'when no block is given' do

      it 'returns an enumerator' do
        expect(result.each).to be_a(Enumerator)
      end
    end
  end

  describe '#initialize' do

    it 'sets the replies' do
      expect(result.replies).to eq([ reply ])
    end
  end

  describe '#returned_count' do

    context 'when the reply is for a read command' do

      let(:documents) do
        [{ 'ismaster' => true, 'ok' => 1.0 }]
      end

      it 'returns the number returned' do
        expect(result.returned_count).to eq(1)
      end
    end

    context 'when the reply is for a write command' do

      context 'when the write is acknowledged' do

        let(:documents) do
          [{ "ok" => 1, "n" => 2 }]
        end

        it 'returns the number returned' do
          expect(result.returned_count).to eq(1)
        end
      end

      context 'when the write is not acknowledged' do

        let(:reply) { nil }

        it 'returns zero' do
          expect(result.returned_count).to eq(0)
        end
      end
    end
  end

  describe '#successful?' do

    context 'when the reply is for a read command' do

      let(:documents) do
        [{ 'ismaster' => true, 'ok' => 1.0 }]
      end

      it 'returns true' do
        expect(result).to be_successful
      end
    end

    context 'when the reply is for a write command' do

      context 'when the write is acknowledged' do

        context 'when ok is 1' do

          let(:documents) do
            [{ "ok" => 1, "n" => 2 }]
          end

          it 'returns true' do
            expect(result).to be_successful
          end
        end

        context 'when ok is not 1' do

          let(:documents) do
            [{ "ok" => 0, "n" => 0 }]
          end

          it 'returns false' do
            expect(result).to_not be_successful
          end
        end
      end

      context 'when the write is not acknowledged' do

        let(:reply) { nil }

        it 'returns true' do
          expect(result).to be_successful
        end
      end
    end
  end

  describe '#written_count' do

    context 'when the reply is for a read command' do

      let(:documents) do
        [{ 'ismaster' => true, 'ok' => 1.0 }]
      end

      it 'returns the number written' do
        expect(result.written_count).to eq(0)
      end
    end

    context 'when the reply is for a write command' do

      let(:documents) do
        [{ "ok" => 1, "n" => 2 }]
      end

      it 'returns the number written' do
        expect(result.written_count).to eq(2)
      end
    end
  end
end
