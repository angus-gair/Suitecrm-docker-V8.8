/**
 * SuiteCRM is a customer relationship management program developed by SalesAgility Ltd.
 * Copyright (C) 2024 SalesAgility Ltd.
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Affero General Public License version 3 as published by the
 * Free Software Foundation with the addition of the following permission added
 * to Section 15 as permitted in Section 7(a): FOR ANY PART OF THE COVERED WORK
 * IN WHICH THE COPYRIGHT IS OWNED BY SALESAGILITY, SALESAGILITY DISCLAIMS THE
 * WARRANTY OF NON INFRINGEMENT OF THIRD PARTY RIGHTS.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * In accordance with Section 7(b) of the GNU Affero General Public License
 * version 3, these Appropriate Legal Notices must retain the display of the
 * "Supercharged by SuiteCRM" logo. If the display of the logos is not reasonably
 * feasible for technical reasons, the Appropriate Legal Notices must display
 * the words "Supercharged by SuiteCRM".
 */

import {Injectable} from '@angular/core';
import {take} from 'rxjs/operators';
import {RecordActionData, RecordActionHandler} from '../record.action';
import {MessageService} from '../../../../services/message/message.service';
import {ModuleNavigation} from '../../../../services/navigation/module-navigation/module-navigation.service';
import {NotificationStore} from '../../../../store/notification/notification.store';
import {RecentlyViewedService} from "../../../../services/navigation/recently-viewed/recently-viewed.service";
import {RecordPaginationService} from "../../store/record-pagination/record-pagination.service";
import {SystemConfigStore} from "../../../../store/system-config/system-config.store";
import {ViewMode} from "../../../../common/views/view.model";

@Injectable({
    providedIn: 'root'
})
export class RecordSaveContinueAction extends RecordActionHandler {

    key = 'saveContinue';
    modes = ['edit' as ViewMode];

    constructor(
        protected message: MessageService,
        protected navigation: ModuleNavigation,
        protected notificationStore: NotificationStore,
        protected systemConfigStore: SystemConfigStore,
        protected recentlyViewedService: RecentlyViewedService,
        protected recordPaginationService: RecordPaginationService
    ) {
        super();
    }

    run(data: RecordActionData): void {
        const isFieldLoading = Object.keys(data.store.recordStore.getStaging().fields).some(fieldKey => {
            const field = data.store.recordStore.getStaging().fields[fieldKey];
            return field?.loading() ?? false;
        });

        if(isFieldLoading) {
            this.message.addWarningMessageByKey('LBL_LOADING_IN_PROGRESS');
            return ;
        }

        data.store.recordStore.validate().pipe(take(1)).subscribe(valid => {
            if (valid) {
                data.store.saveOnEdit().pipe(take(1)).subscribe(record => {
                    const moduleName = data.store.getModuleName();
                    const id = record.id;
                    this.notificationStore.conditionalNotificationRefresh('edit');
                    const recentlyViewed = this.recentlyViewedService.buildRecentlyViewed(moduleName, id);
                    this.recentlyViewedService.addRecentlyViewed(moduleName, recentlyViewed);
                });
                this.recordPaginationService.triggerNextRecord(true);
                return;
            }

            this.message.addWarningMessageByKey('LBL_VALIDATION_ERRORS');
        });
    }

    shouldDisplay(data: RecordActionData): boolean {
        const isEnabled = this.systemConfigStore.getConfigValue('enable_record_pagination');
        if (!isEnabled) {
            return false;
        }

        const totalRecords = this.recordPaginationService.getTotalRecords();
        const offset = this.recordPaginationService.getOffsetFromUrl();
        if (!totalRecords || !offset ||
            (offset >= totalRecords) ||
            (offset <= 0) ) {
            return false;
        }

        return this.recordPaginationService.checkRecordValid(data.store.getRecordId());
    }
}
