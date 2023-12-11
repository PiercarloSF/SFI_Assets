import { LightningElement, api } from 'lwc';
import { subscribe, unsubscribe } from 'lightning/empApi';
import userId from '@salesforce/user/Id';

export default class GridRefreshContractRecordPage extends LightningElement {
    @api recordId;
    channelName = '/event/Grid_RefreshContractRecrodPage__e';
    userId;

    connectedCallback() {
        this.userId = userId;
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        subscribe(this.channelName, -1, (response) => {
            this.handleMessage(response);
        }).then(subscribed => {
            console.log('subscribed to ', this.channelName);
        });
    }
  
    handleMessage(response){
        if(response.data.payload.CreatedById === this.userId){            
            window.location.reload();
        }
    }
  
    disconnectedCallback() {
      unsubscribe(this.channelName);
    }
}