import { Injectable } from '@nestjs/common';

@Injectable()
export class AppService {
    getHealth() {
        return {
            status: 'ok',
            message: 'Sun UW Platform API is running',
            timestamp: new Date().toISOString(),
        };
    }
}
