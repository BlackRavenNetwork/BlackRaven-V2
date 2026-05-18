// Copyright (c) 2018-2019 The Dash Core developers
// Copyright (c) 2020 The BlackRaven developers
// Distributed under the MIT/X11 software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#ifndef BLACKRAVEN_CRYPTO_BLS_WORKER_CACHE_H
#define BLACKRAVEN_CRYPTO_BLS_WORKER_CACHE_H

// Include complete BLS types before std::shared_future/std::promise (required by MinGW).
#include "bls.h"

#include <future>
#include <map>
#include <memory>
#include <mutex>
#include <vector>

class CBLSWorker;

// Builds and caches different things from CBLSWorker
class CBLSWorkerCache
{
private:
    CBLSWorker& worker;

    std::mutex cacheCs;
    std::map<uint256, std::shared_future<BLSVerificationVectorPtr> > vvecCache;
    std::map<uint256, std::shared_future<CBLSSecretKey> > secretKeyShareCache;
    std::map<uint256, std::shared_future<CBLSPublicKey> > publicKeyShareCache;

public:
    CBLSWorkerCache(CBLSWorker& _worker);

    BLSVerificationVectorPtr BuildQuorumVerificationVector(const uint256& cacheKey, const std::vector<BLSVerificationVectorPtr>& vvecs);
    CBLSSecretKey AggregateSecretKeys(const uint256& cacheKey, const BLSSecretKeyVector& skShares);
    CBLSPublicKey BuildPubKeyShare(const uint256& cacheKey, const BLSVerificationVectorPtr& vvec, const CBLSId& id);

private:
    template <typename T, typename Builder>
    T GetOrBuild(const uint256& cacheKey, std::map<uint256, std::shared_future<T> >& cache, Builder&& builder)
    {
        cacheCs.lock();
        auto it = cache.find(cacheKey);
        if (it != cache.end()) {
            auto f = it->second;
            cacheCs.unlock();
            return f.get();
        }

        std::promise<T> p;
        cache.emplace(cacheKey, p.get_future());
        cacheCs.unlock();

        T v = builder();
        p.set_value(v);
        return v;
    }
};

#endif // BLACKRAVEN_CRYPTO_BLS_WORKER_CACHE_H
