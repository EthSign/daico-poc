import {dataSource} from '@graphprotocol/graph-ts'
import {
    BeneficiaryChanged as BeneficiaryChangedEvent,
    FlowRateChanged as FlowRateChangedEvent,
    FundAdded as FundAddedEvent,
    FundsRefunded as FundsRefundedEvent,
    FundsWithdrawn as FundsWithdrawnEvent,
    Initialized as InitializedEvent,
    OwnershipTransferred as OwnershipTransferredEvent,
    RefundEnabled as RefundEnabledEvent
} from '../generated/ICOVault/ICOVault'
import {
    BeneficiaryChanged,
    FlowRateChanged,
    FundAdded,
    FundsRefunded,
    FundsWithdrawn,
    Initialized,
    OwnershipTransferred,
    RefundEnabled
} from '../generated/schema'

export function handleBeneficiaryChanged(event: BeneficiaryChangedEvent): void {
    let entity = new BeneficiaryChanged(
        event.transaction.hash.concatI32(event.logIndex.toI32())
    )
    entity.oldBeneficiary = event.params.oldBeneficiary
    entity.newBeneficiary = event.params.newBeneficiary

    entity.blockNumber = event.block.number
    entity.blockTimestamp = event.block.timestamp
    entity.transactionHash = event.transaction.hash

    const context = dataSource.context()
    entity.instance = context.getBytes('instance')

    entity.save()
}

export function handleFlowRateChanged(event: FlowRateChangedEvent): void {
    let entity = new FlowRateChanged(
        event.transaction.hash.concatI32(event.logIndex.toI32())
    )
    entity.asset = event.params.asset
    entity.oldRate = event.params.oldRate
    entity.newRate = event.params.newRate

    entity.blockNumber = event.block.number
    entity.blockTimestamp = event.block.timestamp
    entity.transactionHash = event.transaction.hash

    const context = dataSource.context()
    entity.instance = context.getBytes('instance')

    entity.save()
}

export function handleFundAdded(event: FundAddedEvent): void {
    let entity = new FundAdded(
        event.transaction.hash.concatI32(event.logIndex.toI32())
    )
    entity.asset = event.params.asset
    entity.investor = event.params.investor
    entity.amount = event.params.amount
    entity.amountOffered = event.params.amountOffered

    entity.blockNumber = event.block.number
    entity.blockTimestamp = event.block.timestamp
    entity.transactionHash = event.transaction.hash

    const context = dataSource.context()
    entity.instance = context.getBytes('instance')

    entity.save()
}

export function handleFundsRefunded(event: FundsRefundedEvent): void {
    let entity = new FundsRefunded(
        event.transaction.hash.concatI32(event.logIndex.toI32())
    )
    entity.asset = event.params.asset
    entity.investor = event.params.investor
    entity.amount = event.params.amount

    entity.blockNumber = event.block.number
    entity.blockTimestamp = event.block.timestamp
    entity.transactionHash = event.transaction.hash

    const context = dataSource.context()
    entity.instance = context.getBytes('instance')

    entity.save()
}

export function handleFundsWithdrawn(event: FundsWithdrawnEvent): void {
    let entity = new FundsWithdrawn(
        event.transaction.hash.concatI32(event.logIndex.toI32())
    )
    entity.asset = event.params.asset
    entity.amount = event.params.amount

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

export function handleRefundEnabled(event: RefundEnabledEvent): void {
    let entity = new RefundEnabled(
        event.transaction.hash.concatI32(event.logIndex.toI32())
    )

    entity.blockNumber = event.block.number
    entity.blockTimestamp = event.block.timestamp
    entity.transactionHash = event.transaction.hash

    const context = dataSource.context()
    entity.instance = context.getBytes('instance')

    entity.save()
}
