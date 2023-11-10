import {DataSourceContext} from '@graphprotocol/graph-ts'
import {DAICOCustomDeployed as DAICOCustomDeployedEvent} from '../generated/DAICODeployer/DAICODeployer'
import {DAICOCustomDeployed} from '../generated/schema'
import {ICOVault} from '../generated/templates'

export function handleDAICOCustomDeployed(
    event: DAICOCustomDeployedEvent
): void {
    let entity = new DAICOCustomDeployed(event.params.instance)
    entity.deployer = event.params.deployer
    entity.implementataion = event.params.implemetation
    entity.module = event.params.module
    entity.save()

    let context = new DataSourceContext()
    context.setBytes('instance', event.params.instance)

    if (event.params.module == 'ICOVault') {
        ICOVault.createWithContext(event.params.implemetation, context)
    }
}
