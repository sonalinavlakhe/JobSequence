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
    return false if dependency.nil?
    visited_jobs = []
    
    while @jobs[dependency]       
      visited_jobs << dependency
      dependency = @jobs[dependency]
      return true if visited_jobs.include?(dependency)
    end

    false
  end
end
