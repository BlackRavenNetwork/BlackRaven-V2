#include "amount.h"
#include "founder_payment.h"
#include "script/script.h"
#include "test/test_blackraven.h"

#include <boost/test/unit_test.hpp>
#include <limits.h>

BOOST_FIXTURE_TEST_SUITE(founder_payment_tests, BasicTestingSetup)

static CMutableTransaction CoinbaseWithMinerOutput(CAmount amount)
{
    CMutableTransaction tx;
    tx.vin.resize(1);
    tx.vin[0].prevout.SetNull();
    tx.vout.emplace_back(amount, CScript() << OP_TRUE);
    return tx;
}

BOOST_AUTO_TEST_CASE(inactive_founder_payment_does_not_add_output)
{
    CMutableTransaction tx = CoinbaseWithMinerOutput(5000 * COIN);
    CTxOut txoutFounder;

    FounderPayment founderPayment({}, INT_MAX, "B75r9F5RG37pDjKWumQyF7e8V5EDZXW7W2");
    founderPayment.FillFounderPayment(tx, 1, 5000 * COIN, txoutFounder);

    BOOST_CHECK_EQUAL(tx.vout.size(), 1U);
    BOOST_CHECK(txoutFounder == CTxOut());
    BOOST_CHECK_EQUAL(tx.vout[0].nValue, 5000 * COIN);
}

BOOST_AUTO_TEST_CASE(zero_founder_payment_does_not_add_output)
{
    CMutableTransaction tx = CoinbaseWithMinerOutput(5000 * COIN);
    CTxOut txoutFounder;
    std::vector<FounderRewardStructure> rewardStructures = {{INT_MAX, 0}};

    FounderPayment founderPayment(rewardStructures, 1, "B75r9F5RG37pDjKWumQyF7e8V5EDZXW7W2");
    founderPayment.FillFounderPayment(tx, 1, 5000 * COIN, txoutFounder);

    BOOST_CHECK_EQUAL(tx.vout.size(), 1U);
    BOOST_CHECK(txoutFounder == CTxOut());
    BOOST_CHECK_EQUAL(tx.vout[0].nValue, 5000 * COIN);
}

BOOST_AUTO_TEST_CASE(active_founder_payment_adds_output)
{
    CMutableTransaction tx = CoinbaseWithMinerOutput(5000 * COIN);
    CTxOut txoutFounder;
    std::vector<FounderRewardStructure> rewardStructures = {{INT_MAX, 50}};

    FounderPayment founderPayment(rewardStructures, 1, "B75r9F5RG37pDjKWumQyF7e8V5EDZXW7W2");
    founderPayment.FillFounderPayment(tx, 1, 5000 * COIN, txoutFounder);

    BOOST_REQUIRE_EQUAL(tx.vout.size(), 2U);
    BOOST_CHECK(txoutFounder == tx.vout[1]);
    BOOST_CHECK_EQUAL(txoutFounder.nValue, 25 * COIN);
    BOOST_CHECK_EQUAL(tx.vout[0].nValue, 4975 * COIN);
}

BOOST_AUTO_TEST_SUITE_END()
