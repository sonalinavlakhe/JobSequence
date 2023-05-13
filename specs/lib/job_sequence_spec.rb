require 'rspec'
require_relative '../../lib/job_sequence'

RSpec.describe JobSequence do

  describe '#validate_jobs' do
    context 'with valid job sequence' do
      let(:jobs) { {'a' => nil, 'b' => 'c', 'c' => 'a'} }

      it 'does not raise an ArgumentError' do               
        job_sequence = JobSequence.new(jobs)
        expect { job_sequence.send(:validate_jobs) }.not_to raise_error
      end
    end

    context 'with circular dependency' do
      let(:jobs) { {'a'=> nil, 'b'=> 'c', 'c'=> 'f', 'd'=> 'a', 'e'=> nil, 'f'=> 'b'} }

      it 'raises an ArgumentError with the correct message' do
        job_sequence = JobSequence.new(jobs)
        expect { job_sequence.send(:validate_jobs) }.to output("Error: Jobs cannot have circular dependencies\n").to_stdout
      end
    end

    context 'with self-dependency' do
      let(:jobs) {{'a'=> nil, 'b'=> 'b', 'c'=> 'a'}}

      it 'raises an ArgumentError with the correct message' do
        job_sequence = JobSequence.new(jobs)
        expect { job_sequence.send(:validate_jobs) }.to output("Error: Jobs cannot depend on themselves\n").to_stdout
      end
    end
  end
end