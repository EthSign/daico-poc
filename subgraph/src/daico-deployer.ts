import {DataSourceContext} from '@graphprotocol/graph-ts'
import {DAICOCustomDeployed as DAICOCustomDeployedEvent} from '../generated/DAICODeployer/DAICODeployer'
import {DAICustomDeployed} from '../generated/schema'

export function handleDAICOCustomDeployed(
    event: DAICOCustomDeployedEvent
): void {
    let entity = new DAICustomDeployed(event.params.instance)
    entity.deployer = event.params.deployer
    entity.implementataion = event.params.implemetation
    entity.module = event.params.module
    entity.save()

    let context = new DataSourceContext()
    context.setBytes('instance', event.params.instance)
}
