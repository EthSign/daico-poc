import {newMockEvent} from 'matchstick-as'
import {ethereum, Address, BigInt} from '@graphprotocol/graph-ts'
import {
    BeneficiaryChanged,
    FlowRateChanged,
    FundAdded,
    FundsRefunded,
    FundsWithdrawn,
    Initialized,
    OwnershipTransferred,
    RefundEnabled
} from '../generated/ICOVault/ICOVault'

export function createBeneficiaryChangedEvent(
    oldBeneficiary: Address,
    newBeneficiary: Address
): BeneficiaryChanged {
    let beneficiaryChangedEvent = changetype<BeneficiaryChanged>(newMockEvent())

    beneficiaryChangedEvent.parameters = new Array()

    beneficiaryChangedEvent.parameters.push(
        new ethereum.EventParam(
            'oldBeneficiary',
            ethereum.Value.fromAddress(oldBeneficiary)
        )
    )
    beneficiaryChangedEvent.parameters.push(
        new ethereum.EventParam(
            'newBeneficiary',
            ethereum.Value.fromAddress(newBeneficiary)
        )
    )

    return beneficiaryChangedEvent
}

export function createFlowRateChangedEvent(
    asset: Address,
    oldRate: BigInt,
    newRate: BigInt
): FlowRateChanged {
    let flowRateChangedEvent = changetype<FlowRateChanged>(newMockEvent())

    flowRateChangedEvent.parameters = new Array()

    flowRateChangedEvent.parameters.push(
        new ethereum.EventParam('asset', ethereum.Value.fromAddress(asset))
    )
    flowRateChangedEvent.parameters.push(
        new ethereum.EventParam(
            'oldRate',
            ethereum.Value.fromUnsignedBigInt(oldRate)
        )
    )
    flowRateChangedEvent.parameters.push(
        new ethereum.EventParam(
            'newRate',
            ethereum.Value.fromUnsignedBigInt(newRate)
        )
    )

    return flowRateChangedEvent
}

export function createFundAddedEvent(
    asset: Address,
    investor: Address,
    amount: BigInt,
    amountOffered: BigInt
): FundAdded {
    let fundAddedEvent = changetype<FundAdded>(newMockEvent())

    fundAddedEvent.parameters = new Array()

    fundAddedEvent.parameters.push(
        new ethereum.EventParam('asset', ethereum.Value.fromAddress(asset))
    )
    fundAddedEvent.parameters.push(
        new ethereum.EventParam(
            'investor',
            ethereum.Value.fromAddress(investor)
        )
    )
    fundAddedEvent.parameters.push(
        new ethereum.EventParam(
            'amount',
            ethereum.Value.fromUnsignedBigInt(amount)
        )
    )
    fundAddedEvent.parameters.push(
        new ethereum.EventParam(
            'amountOffered',
            ethereum.Value.fromUnsignedBigInt(amountOffered)
        )
    )

    return fundAddedEvent
}

export function createFundsRefundedEvent(
    asset: Address,
    investor: Address,
    amount: BigInt
): FundsRefunded {
    let fundsRefundedEvent = changetype<FundsRefunded>(newMockEvent())

    fundsRefundedEvent.parameters = new Array()

    fundsRefundedEvent.parameters.push(
        new ethereum.EventParam('asset', ethereum.Value.fromAddress(asset))
    )
    fundsRefundedEvent.parameters.push(
        new ethereum.EventParam(
            'investor',
            ethereum.Value.fromAddress(investor)
        )
    )
    fundsRefundedEvent.parameters.push(
        new ethereum.EventParam(
            'amount',
            ethereum.Value.fromUnsignedBigInt(amount)
        )
    )

    return fundsRefundedEvent
}

export function createFundsWithdrawnEvent(
    asset: Address,
    amount: BigInt
): FundsWithdrawn {
    let fundsWithdrawnEvent = changetype<FundsWithdrawn>(newMockEvent())

    fundsWithdrawnEvent.parameters = new Array()

    fundsWithdrawnEvent.parameters.push(
        new ethereum.EventParam('asset', ethereum.Value.fromAddress(asset))
    )
    fundsWithdrawnEvent.parameters.push(
        new ethereum.EventParam(
            'amount',
            ethereum.Value.fromUnsignedBigInt(amount)
        )
    )

    return fundsWithdrawnEvent
}

export function createInitializedEvent(version: BigInt): Initialized {
    let initializedEvent = changetype<Initialized>(newMockEvent())

    initializedEvent.parameters = new Array()

    initializedEvent.parameters.push(
        new ethereum.EventParam(
            'version',
            ethereum.Value.fromUnsignedBigInt(version)
        )
    )

    return initializedEvent
}

export function createOwnershipTransferredEvent(
    previousOwner: Address,
    newOwner: Address
): OwnershipTransferred {
    let ownershipTransferredEvent = changetype<OwnershipTransferred>(
        newMockEvent()
    )

    ownershipTransferredEvent.parameters = new Array()

    ownershipTransferredEvent.parameters.push(
        new ethereum.EventParam(
            'previousOwner',
            ethereum.Value.fromAddress(previousOwner)
        )
    )
    ownershipTransferredEvent.parameters.push(
        new ethereum.EventParam(
            'newOwner',
            ethereum.Value.fromAddress(newOwner)
        )
    )

    return ownershipTransferredEvent
}

export function createRefundEnabledEvent(): RefundEnabled {
    let refundEnabledEvent = changetype<RefundEnabled>(newMockEvent())

    refundEnabledEvent.parameters = new Array()

    return refundEnabledEvent
}
