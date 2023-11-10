import {
    EIP712DomainChanged as EIP712DomainChangedEvent,
    Initialized as InitializedEvent,
    OwnershipTransferred as OwnershipTransferredEvent,
    ProposalCanceled as ProposalCanceledEvent,
    ProposalCreated as ProposalCreatedEvent,
    ProposalExecuted as ProposalExecutedEvent,
    ProposalQueued as ProposalQueuedEvent,
    QuorumNumeratorUpdated as QuorumNumeratorUpdatedEvent,
    VoteCast as VoteCastEvent,
    VoteCastWithParams as VoteCastWithParamsEvent
} from '../generated/templates/DAOGovernorUpgradeable/DAOGovernorUpgradeable'
import {
    EIP712DomainChanged,
    Initialized,
    OwnershipTransferred,
    ProposalCanceled,
    ProposalCreated,
    ProposalExecuted,
    ProposalQueued,
    QuorumNumeratorUpdated,
    VoteCast,
    VoteCastWithParams
} from '../generated/schema'
import {Bytes, dataSource} from '@graphprotocol/graph-ts'

export function handleEIP712DomainChanged(
    event: EIP712DomainChangedEvent
): void {
    let entity = new EIP712DomainChanged(
        event.transaction.hash.concatI32(event.logIndex.toI32())
    )

    entity.blockNumber = event.block.number
    entity.blockTimestamp = event.block.timestamp
    entity.transactionHash = event.transaction.hash

    const context = dataSource.context()
    entity.instance = context.getBytes('instance')

    entity.save()
}

export function handleInitialized(event: InitializedEvent): void {
    let entity = new Initialized(
        event.transaction.hash.concatI32(event.logIndex.toI32())
    )
    entity.version = event.params.version

    entity.blockNumber = event.block.number
    entity.blockTimestamp = event.block.timestamp
    entity.transactionHash = event.transaction.hash

    const context = dataSource.context()
    entity.instance = context.getBytes('instance')

    entity.save()
}

export function handleOwnershipTransferred(
    event: OwnershipTransferredEvent
): void {
    let entity = new OwnershipTransferred(
        event.transaction.hash.concatI32(event.logIndex.toI32())
    )
    entity.previousOwner = event.params.previousOwner
    entity.newOwner = event.params.newOwner

    entity.blockNumber = event.block.number
    entity.blockTimestamp = event.block.timestamp
    entity.transactionHash = event.transaction.hash

    const context = dataSource.context()
    entity.instance = context.getBytes('instance')

    entity.save()
}

export function handleProposalCanceled(event: ProposalCanceledEvent): void {
    let entity = new ProposalCanceled(
        event.transaction.hash.concatI32(event.logIndex.toI32())
    )
    entity.proposalId = event.params.proposalId

    entity.blockNumber = event.block.number
    entity.blockTimestamp = event.block.timestamp
    entity.transactionHash = event.transaction.hash

    const context = dataSource.context()
    entity.instance = context.getBytes('instance')

    entity.save()
}

export function handleProposalCreated(event: ProposalCreatedEvent): void {
    let entity = new ProposalCreated(
        event.transaction.hash.concatI32(event.logIndex.toI32())
    )
    entity.proposalId = event.params.proposalId
    entity.proposer = event.params.proposer
    entity.targets = changetype<Bytes[]>(event.params.targets)
    entity.values = event.params.values
    entity.signatures = event.params.signatures
    entity.calldatas = event.params.calldatas
    entity.voteStart = event.params.voteStart
    entity.voteEnd = event.params.voteEnd
    entity.description = event.params.description

    entity.blockNumber = event.block.number
    entity.blockTimestamp = event.block.timestamp
    entity.transactionHash = event.transaction.hash

    const context = dataSource.context()
    entity.instance = context.getBytes('instance')

    entity.save()
}

export function handleProposalExecuted(event: ProposalExecutedEvent): void {
    let entity = new ProposalExecuted(
        event.transaction.hash.concatI32(event.logIndex.toI32())
    )
    entity.proposalId = event.params.proposalId

    entity.blockNumber = event.block.number
    entity.blockTimestamp = event.block.timestamp
    entity.transactionHash = event.transaction.hash

    const context = dataSource.context()
    entity.instance = context.getBytes('instance')

    entity.save()
}

export function handleProposalQueued(event: ProposalQueuedEvent): void {
    let entity = new ProposalQueued(
        event.transaction.hash.concatI32(event.logIndex.toI32())
    )
    entity.proposalId = event.params.proposalId
    entity.etaSeconds = event.params.etaSeconds

    entity.blockNumber = event.block.number
    entity.blockTimestamp = event.block.timestamp
    entity.transactionHash = event.transaction.hash

    const context = dataSource.context()
    entity.instance = context.getBytes('instance')

    entity.save()
}

export function handleQuorumNumeratorUpdated(
    event: QuorumNumeratorUpdatedEvent
): void {
    let entity = new QuorumNumeratorUpdated(
        event.transaction.hash.concatI32(event.logIndex.toI32())
    )
    entity.oldQuorumNumerator = event.params.oldQuorumNumerator
    entity.newQuorumNumerator = event.params.newQuorumNumerator

    entity.blockNumber = event.block.number
    entity.blockTimestamp = event.block.timestamp
    entity.transactionHash = event.transaction.hash

    const context = dataSource.context()
    entity.instance = context.getBytes('instance')

    entity.save()
}

export function handleVoteCast(event: VoteCastEvent): void {
    let entity = new VoteCast(
        event.transaction.hash.concatI32(event.logIndex.toI32())
    )
    entity.voter = event.params.voter
    entity.proposalId = event.params.proposalId
    entity.support = event.params.support
    entity.weight = event.params.weight
    entity.reason = event.params.reason

    entity.blockNumber = event.block.number
    entity.blockTimestamp = event.block.timestamp
    entity.transactionHash = event.transaction.hash

    const context = dataSource.context()
    entity.instance = context.getBytes('instance')

    entity.save()
}

export function handleVoteCastWithParams(event: VoteCastWithParamsEvent): void {
    let entity = new VoteCastWithParams(
        event.transaction.hash.concatI32(event.logIndex.toI32())
    )
    entity.voter = event.params.voter
    entity.proposalId = event.params.proposalId
    entity.support = event.params.support
    entity.weight = event.params.weight
    entity.reason = event.params.reason
    entity.params = event.params.params

    entity.blockNumber = event.block.number
    entity.blockTimestamp = event.block.timestamp
    entity.transactionHash = event.transaction.hash

    const context = dataSource.context()
    entity.instance = context.getBytes('instance')

    entity.save()
}
