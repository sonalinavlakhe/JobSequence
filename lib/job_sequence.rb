class JobSequence
  def initialize(jobs)
    @jobs = jobs
  end

  def sequence_jobs
    validate_jobs
    
    job_queue = []
    job_dependencies = @jobs.clone

    job_dependencies.each do |job, dependency|
      if dependency.nil?
        job_queue << job
        job_dependencies.delete(job)
      end
    end

    while job_dependencies.any?
      job_dependencies.each do |job, dependency|
        next unless job_queue.include?(dependency)
        job_queue << job
        job_dependencies.delete(job)
      end
    end

    job_queue.join('')
  end

  def validate_jobs
     begin
      @jobs.each do |job, dependency|
        raise ArgumentError, 'Jobs cannot depend on themselves' if job == dependency
        raise ArgumentError, 'Jobs cannot have circular dependencies' if circular_dependency?(job, dependency)
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
