/**
 * types.ts — Rating Engine Type Definitions
 * Facility: LM21M0136 Appendix 6
 */

export type Territory = 'US_CA_MX_CARIB' | 'ROW';
export type VesselType =
  | 'SAILING'
  | 'MOTOR'
  | 'CATAMARAN'
  | 'TRIMARAN'
  | 'POWER'
  | 'OTHER';
export type UseType = 'PRIVATE' | 'CHARTER' | 'BAREBOAT';
export type NavModifier =
  | 'MED_EU'
  | 'AUS_NZ'
  | 'WEST_COAST_US_MX'
  | 'CABO_SAN_LUCAS_SEASONAL'
  | 'CHESAPEAKE_SEASONAL'
  | null;

export type TransitRoute =
  | 'TRANS_PACIFIC'
  | 'TRANS_ATLANTIC'
  | 'INDIAN_OCEAN'
  | 'HAWAII'
  | 'BERMUDA'
  | 'PANAMA';

export type TransitDirection = 'ONE_WAY' | 'ROUND_TRIP';

export interface Transit {
  route: TransitRoute;
  direction: TransitDirection;
}

export interface RiskInput {
  hullValue: number;
  vesselType: VesselType;
  yearBuilt: number;
  lengthFeet: number;
  territory: Territory;
  useType: UseType;
  navAreaModifier?: NavModifier;
  maxSpeedKnots?: number;
  liabilityLimit?: number;
  tenderValue?: number;
  personalProperty?: number;
  electronicsValue?: number;
  includeTowing?: boolean;
  includeTrailer?: boolean;
  trailerValue?: number;
  includeWindstorm?: boolean;
  hullDeductiblePct?: number;
  hasAutoFireExt?: boolean;
  professionalCrew?: boolean;
  hasYachtingQual?: boolean;
  dieselOnly?: boolean;
  englishLaw?: boolean;
  inlandWatersOnly?: boolean;
  faultClaimsCY?: number;
  faultClaimsPY?: number;
  faultClaims2Y?: number;
  faultClaims3Y?: number;
  noFaultClaims?: number;
  transits?: Transit[];
  layUpMonths?: number;
}

export interface AppliedFactor {
  code: string;
  label: string;
  pct: number;
}

export interface OptionalPremiums {
  tender: number;
  personalProperty: number;
  electronics: number;
  towing: number;
  trailer: number;
  transits: number;
}

export interface RatingBreakdown {
  baseRatePct: number;
  adjustedRatePct: number;
  netAdjustmentPct: number;
  discounts: AppliedFactor[];
  loadings: AppliedFactor[];
  rateTableSource: string;
}

export interface Deductibles {
  hull: number;
  hullPct: number;
  liability: number;
}

export interface RatingResult {
  hullPremium: number;
  liabilityPremium: number;
  optionalPremiums: OptionalPremiums;
  totalPremium: number;
  ratingBreakdown: RatingBreakdown;
  deductibles: Deductibles;
  minimumPremiumApplied: boolean;
  vesselAge: number;
  uwFlags: string[];
}
