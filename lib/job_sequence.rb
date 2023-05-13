class JobSequence
  def initialize(jobs)
    @jobs = jobs
  end

  def validate_jobs
     begin
      @jobs.each do |job, dependency|
        raise ArgumentError, 'Jobs cannot depend on themselves' if job == dependency
      end
    rescue ArgumentError => e
      puts "Error: #{e.message}"
    end
  end

  private


  def circular_dependency?(job, dependency)
  end
end
