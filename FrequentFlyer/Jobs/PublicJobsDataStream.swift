import RxSwift

class PublicJobsDataStream {
    let concourseURL: String

    var jobsService = JobsService()

    init(concourseURL: String) {
        self.concourseURL = concourseURL
    }
}

extension PublicJobsDataStream: JobsDataStream {
    func open(forPipeline pipeline: Pipeline) -> Observable<[JobGroupSection]> {
        return jobsService
            .getPublicJobs(forPipeline: pipeline, concourseURL: concourseURL)
            .map { jobs in
                var sectionJobsMap: [String : [Job]] = [:]
                jobs.forEach { job in
                    var groupName: String
                    if let firstGroupName = job.groups.first {
                        groupName = firstGroupName
                    } else {
                        groupName = "ungrouped"
                    }

                    if sectionJobsMap[groupName] != nil {
                        sectionJobsMap[groupName]?.append(job)
                    } else {
                        sectionJobsMap[groupName] = [job]
                    }
                }

                return sectionJobsMap.values
                    .map { jobs in
                        var section = JobGroupSection()
                        section.items.append(contentsOf: jobs)
                        return section
                }
        }
    }
}
