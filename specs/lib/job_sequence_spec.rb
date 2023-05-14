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

  describe '#circular_dependency?' do
    let(:job_sequence) { JobSequence.new(jobs) }

    context 'with circular dependency' do
      let(:jobs) {{'a' => 'b', 'b' => 'c', 'c' => 'a'}}
      it 'returns true' do
        expect(job_sequence.send(:circular_dependency?, 'a', 'b')).to be true
      end
    end

    context 'with no circular dependency' do
      let(:jobs) {{'a' => nil, 'b' => 'a', 'c' => 'b'}}
      it 'returns false' do
        expect(job_sequence.send(:circular_dependency?, 'a', nil)).to be false
      end
    end
  end

  describe '#sequence_jobs' do
    context 'when given an empty hash' do
      let(:jobs) { {} }

      it 'returns an empty string' do
        expect(JobSequence.new(jobs).sequence_jobs).to eq ''
      end
    end

    context 'when given a single job' do
      let(:jobs) {{'a' => nil}}

      it 'returns the job name' do
        expect(JobSequence.new(jobs).sequence_jobs).to eq 'a'
      end
    end

    context 'when given multiple jobs with no dependencies' do
      let(:jobs) {{'a' => nil, 'b' => nil, 'c' => nil}}
      
      it 'returns the jobs in any order' do
        expect(JobSequence.new(jobs).sequence_jobs).to match(/abc/)
      end
    end

    context 'when given multiple jobs with dependencies' do
      let(:jobs) {{'a'=> nil, 'b'=> 'c', 'c'=> 'f', 'd'=> 'a', 'e'=> 'b', 'f'=> nil}}

      it 'returns the jobs in the correct order' do
        expect(JobSequence.new(jobs).sequence_jobs).to eq 'afcdbe'
      end
    end

    context 'when given jobs with circular dependencies' do
      let(:jobs) {{'a'=> nil, 'b'=> 'c', 'c'=> 'f', 'd'=> 'a', 'e'=> nil, 'f'=> 'b'}}

      it 'raises an ArgumentError' do
        expect { JobSequence.new(jobs).sequence_jobs }.to raise_error(ArgumentError, 'Jobs cannot have circular dependencies')
      end
    end

    context 'when given jobs that depend on themselves' do
      let(:jobs) {{'a'=> nil, 'b'=> nil, 'c'=> 'c'}}

      it 'raises an ArgumentError' do
        expect { JobSequence.new(jobs).sequence_jobs }.to raise_error(ArgumentError, 'Jobs cannot depend on themselves')
      end
    end
  end
end