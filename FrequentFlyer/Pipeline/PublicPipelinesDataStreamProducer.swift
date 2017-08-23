import RxSwift

class PublicPipelinesDataStreamProducer {
    var publicPipelinesService = PublicPipelinesService()

    func openStream(forConcourseWithURL concourseURL: String) -> Observable<[PipelineGroupSection]> {
        return publicPipelinesService.getPipelines(forConcourseWithURL: concourseURL)
            .map { pipelines in
                var publicPipelines = pipelines.filter { $0.isPublic }
                publicPipelines = publicPipelines.flatMap { $0 }

                let pipelinesByTeamName = self.groupByTeamName(publicPipelines)
                let sortedPipelineGroups = self.sortPipelineGroupsByTeamName(pipelinesByTeamName)

                var groupSections = [PipelineGroupSection]()
                sortedPipelineGroups.forEach { pipelineGroup in
                    var newSection = PipelineGroupSection()
                    newSection.items.append(contentsOf: pipelineGroup)
                    groupSections.append(newSection)
                }

                return groupSections
        }
    }

    private func groupByTeamName(_ pipelines: [Pipeline]) -> [[Pipeline]] {
        var groupedPipelines: [String : [Pipeline]] = [:]
        pipelines.forEach { pipeline in
            if groupedPipelines[pipeline.teamName] != nil {
                groupedPipelines[pipeline.teamName]!.append(pipeline)
                return
            }

            groupedPipelines[pipeline.teamName] = [pipeline]
        }

        return groupedPipelines.values.map { $0 }

    }

    private func sortPipelineGroupsByTeamName(_ groups: [[Pipeline]]) -> [[Pipeline]] {
        return groups.sorted { lhs, rhs in
            guard let lhsGroupTeamName = lhs.first?.teamName
                else { return false }
            guard let rhsGroupTeamName = rhs.first?.teamName
                else { return false }

            return lhsGroupTeamName < rhsGroupTeamName
        }
    }
}
