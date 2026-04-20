"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MonthlyStatsModule = void 0;
const common_1 = require("@nestjs/common");
const mongoose_1 = require("@nestjs/mongoose");
const monthly_stats_schema_1 = require("../monthly-stats/schemas/monthly-stats.schema");
const monthly_stats_service_1 = require("./monthly-stats.service");
let MonthlyStatsModule = class MonthlyStatsModule {
};
exports.MonthlyStatsModule = MonthlyStatsModule;
exports.MonthlyStatsModule = MonthlyStatsModule = __decorate([
    (0, common_1.Module)({
        imports: [
            mongoose_1.MongooseModule.forFeature([
                {
                    name: 'MonthlyStats',
                    schema: monthly_stats_schema_1.MonthlyStatsSchema,
                    collection: 'monthly_stats',
                },
            ]),
        ],
        providers: [monthly_stats_service_1.MonthlyStatsService],
        exports: [monthly_stats_service_1.MonthlyStatsService],
    })
], MonthlyStatsModule);
//# sourceMappingURL=monthly-stats.module.js.map