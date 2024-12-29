export type Item = {
    name: string
    assignees: AssigneeDecision[]
    partition: number
}

type AssigneeDecision = {
    uid: string
    parts: number | null
}
