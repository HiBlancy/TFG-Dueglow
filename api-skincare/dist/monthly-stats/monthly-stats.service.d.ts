import { Model } from 'mongoose';
export declare class MonthlyStatsService {
    private monthlyStatsModel;
    constructor(monthlyStatsModel: Model<any>);
    updateOrCreate(userId: string, year: number, month: number, incrementCount: number): Promise<any>;
}
