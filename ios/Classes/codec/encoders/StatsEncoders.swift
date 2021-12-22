//
// Created by Ikbal Kaya on 21/12/2021.
//

import Foundation

public class StatsEncoders: NSObject {
    @objc
    public static let encodeStats: (ARTStats) -> [String: Any] = { stats in
        [
            TxStats_all: encodeStatsMessageTypes(stats.all),
            TxStats_apiRequests: encodeStatsRequestCount(stats.apiRequests),
            TxStats_channels:encodeStatsResourceCount(stats.channels),
            TxStats_connections:encodeStatsConnectionTypes(stats.connections),
            TxStats_inbound:encodeStatsMessageTraffic(stats.inbound),
            TxStats_intervalId:stats.intervalId,
            TxStats_outbound:encodeStatsMessageTraffic(stats.outbound),
            TxStats_persisted:encodeStatsMessageTypes(stats.persisted),
            TxStats_tokenRequests: encodeStatsRequestCount(stats.tokenRequests)
        ]
    }

    static let encodeStatsMessageTypes: (ARTStatsMessageTypes) -> [String: Any] = { types in
        [
            TxStatsMessageTypes_all: encodeStatsMessageCount(types.all),
            TxStatsMessageTypes_messages: encodeStatsMessageCount(types.messages),
            TxStatsMessageTypes_presence: encodeStatsMessageCount(types.presence)
        ]
    }

    static let encodeStatsMessageCount: (ARTStatsMessageCount) -> [String: Any] = { count in
        [
            TxStatsMessageCount_count: count.count,
            TxStatsMessageCount_data:count.data
        ]
    }

    static let encodeStatsRequestCount: (ARTStatsRequestCount) -> [String: Any] = { count in
        [
            TxStatsRequestCount_failed: count.failed,
            TxStatsRequestCount_refused: count.refused,
            TxStatsRequestCount_succeeded: count.succeeded
        ]
    }

    static let encodeStatsResourceCount: (ARTStatsResourceCount) -> [String: Any] = { count in
        [
            TxStatsResourceCount_mean:count.mean,
            TxStatsResourceCount_min:count.min,
            TxStatsResourceCount_opened:count.opened,
            TxStatsResourceCount_peak:count.peak,
            TxStatsResourceCount_refused:count.refused
        ]
    }

    static let encodeStatsConnectionTypes: (ARTStatsConnectionTypes) -> [String: Any] = { types in
        [
            TxStatsConnectionTypes_all: encodeStatsResourceCount(types.all),
            TxStatsConnectionTypes_plain: encodeStatsResourceCount(types.plain),
            TxStatsConnectionTypes_tls: encodeStatsResourceCount(types.tls),
        ]
    }

    static let encodeStatsMessageTraffic: (ARTStatsMessageTraffic) -> [String: Any] = { types in
        [
            TxStatsMessageTraffic_all: encodeStatsMessageTypes(types.all),
            TxStatsMessageTraffic_realtime: encodeStatsMessageTypes(types.realtime),
            TxStatsMessageTraffic_rest: encodeStatsMessageTypes(types.rest),
            TxStatsMessageTraffic_webhook: encodeStatsMessageTypes(types.webhook)
        ]
    }
}
