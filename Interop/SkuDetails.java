/* Copyright (c) 2012 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.fuse.billing.android;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Represents an in-app product's listing details.
 */
public class SkuDetails {
    private final String mSku;
    private final String mType;
    private final String mPrice;
    private final long mPriceAmountMicros;
    private final String mPriceCurrencyCode;
    private final String mTitle;
    private final String mDescription;
    private final JSONObject mJson;

    public SkuDetails(String jsonSkuDetails) throws JSONException {
        this(new JSONObject(jsonSkuDetails));
    }

    public SkuDetails(JSONObject o) {
        mJson = o;
        mSku = o.optString("productId");
        mType = o.optString("type");
        mPrice = o.optString("price");
        mPriceAmountMicros = o.optLong("price_amount_micros");
        mPriceCurrencyCode = o.optString("price_currency_code");
        mTitle = o.optString("title");
        mDescription = o.optString("description");
    }

    public static SkuDetails createForTestProduct(String sku) throws JSONException {
        JSONObject o = new JSONObject();
        o.put("productId", sku);
        o.put("type", IabHelper.ITEM_TYPE_INAPP);
        o.put("price", "$0.99");
        o.put("price_amount_micros", 99);
        o.put("price_currency_code", "USD");
        o.put("title", "Sample Title");
        o.put("description", "A static test product");
        return new SkuDetails(o);
    }

    public String getSku() { return mSku; }
    public String getType() { return mType; }
    public String getPrice() { return mPrice; }
    public long getPriceAmountMicros() { return mPriceAmountMicros; }
    public String getPriceCurrencyCode() { return mPriceCurrencyCode; }
    public String getTitle() { return mTitle; }
    public String getDescription() { return mDescription; }
    public JSONObject toJSON() { return mJson; }

    @Override
    public String toString() {
        return "SkuDetails:" + mJson;
    }
}
