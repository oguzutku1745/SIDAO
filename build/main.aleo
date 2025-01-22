import credits.aleo;
import token_registry.aleo;
program dao_test.aleo;

struct TokenMetadata:
    token_id as field;
    name as u128;
    symbol as u128;
    decimals as u8;
    supply as u128;
    max_supply as u128;
    admin as address;
    external_authorization_required as boolean;
    external_authorization_party as address;

struct TokenOwner:
    account as address;
    token_id as field;

record Claimable:
    owner as address.private;
    amount as u64.private;
    project_id as field.private;
    stage as u8.private;

struct ClaimKeyGen:
    claim_owner as address;
    project_id as field;
    stage as u8;

struct ProjectInfo:
    title as u128;
    image as u128;
    description as field;
    funding_target as u64;
    funded_amount as u64;
    treasury_address as address;
    stage as u8;
    reserved_share as u64;

struct Project:
    id as field;
    project_owner as address;
    info as ProjectInfo;

struct Claims:
    claim_owner as address;
    amount as u64;
    project_id as field;
    stage as u8;

struct RoundProjectIds:
    project1 as field;
    project2 as field;
    project3 as field;
    project4 as field;
    project5 as field;
    project6 as field;
    project7 as field;
    project8 as field;
    project9 as field;
    project10 as field;
    project11 as field;
    project12 as field;
    project13 as field;
    project14 as field;
    project15 as field;

struct Round:
    total_rounds as u32;
    active_project_count as u16;
    total_project_count as u64;

mapping round_info:
    key as u8.public;
    value as Round.public;

mapping round_project_ids:
    key as u64.public;
    value as RoundProjectIds.public;

mapping project_info:
    key as field.public;
    value as Project.public;

mapping active_project_info:
    key as u16.public;
    value as field.public;

mapping is_round_active:
    key as u32.public;
    value as boolean.public;

mapping public_investor_share:
    key as field.public;
    value as Claims.public;

function init_round:
    assert.eq self.caller aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px;
    async init_round self.caller into r0;
    output r0 as dao_test.aleo/init_round.future;

finalize init_round:
    input r0 as address.public;
    cast 0u32 0u16 0u64 into r1 as Round;
    set r1 into round_info[1u8];

function open_new_round:
    input r0 as u32.public;
    cast 0field 0field 0field 0field 0field 0field 0field 0field 0field 0field 0field 0field 0field 0field 0field into r1 as RoundProjectIds;
    assert.eq self.caller aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px;
    async open_new_round r0 r1 into r2;
    output r2 as dao_test.aleo/open_new_round.future;

finalize open_new_round:
    input r0 as u32.public;
    input r1 as RoundProjectIds.public;
    get round_info[1u8] into r2;
    assert.eq r2.total_rounds r0;
    get is_round_active[r0] into r3;
    assert.eq r3 false;
    set true into is_round_active[r0];
    cast r2.total_rounds into r4 as u64;
    add r4 1u64 into r5;
    set r1 into round_project_ids[r5];
    add r2.total_rounds 1u32 into r6;
    cast r6 0u16 r2.total_project_count into r7 as Round;
    set r7 into round_info[1u8];

function close_round:
    input r0 as address.public;
    assert.eq self.caller aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px;
    async close_round self.caller into r1;
    output r1 as dao_test.aleo/close_round.future;

finalize close_round:
    input r0 as address.public;
    get round_info[1u8] into r1;
    get is_round_active[r1.total_rounds] into r2;
    assert.eq r2 true;
    set false into is_round_active[r1.total_rounds];
    cast r1.total_rounds 0u16 r1.total_project_count into r3 as Round;
    set r3 into round_info[1u8];

function submit_project:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u128.public;
    input r3 as u128.public;
    input r4 as field.public;
    input r5 as u8.public;
    input r6 as u64.public;
    input r7 as u128.public;
    input r8 as u128.public;
    input r9 as u64.public;
    cast r2 r3 r4 r6 0u64 r1 r5 r9 into r10 as ProjectInfo;
    hash.bhp256 r10 into r11 as field;
    is.eq r5 1u8 into r12;
    is.eq r5 2u8 into r13;
    is.eq r5 3u8 into r14;
    or r13 r14 into r15;
    ternary r15 20000u64 0u64 into r16;
    ternary r12 10000u64 r16 into r17;
    lt r6 r17 into r18;
    assert.eq r18 true;
    call token_registry.aleo/register_token r11 r7 r8 6u8 1_000_000_000_000_000u128 false dao_test.aleo into r19;
    call token_registry.aleo/set_role r11 dao_test.aleo 3u8 into r20;
    async submit_project r0 r1 r2 r3 r4 r5 r6 r11 r10 r19 r20 into r21;
    output r21 as dao_test.aleo/submit_project.future;

finalize submit_project:
    input r0 as address.public;
    input r1 as address.public;
    input r2 as u128.public;
    input r3 as u128.public;
    input r4 as field.public;
    input r5 as u8.public;
    input r6 as u64.public;
    input r7 as field.public;
    input r8 as ProjectInfo.public;
    input r9 as token_registry.aleo/register_token.future;
    input r10 as token_registry.aleo/set_role.future;
    get round_info[1u8] into r11;
    get is_round_active[r11.total_rounds] into r12;
    assert.eq r12 true;
    await r9;
    await r10;
    get round_info[1u8] into r13;
    add r13.active_project_count 1u16 into r14;
    set r7 into active_project_info[r14];
    cast r7 r0 r8 into r15 as Project;
    set r15 into project_info[r7];
    cast r13.total_rounds into r16 as u64;
    get round_project_ids[r16] into r17;
    is.eq r14 1u16 into r18;
    ternary r18 r7 r17.project1 into r19;
    is.eq r14 2u16 into r20;
    ternary r20 r7 r17.project2 into r21;
    is.eq r14 3u16 into r22;
    ternary r22 r7 r17.project3 into r23;
    is.eq r14 4u16 into r24;
    ternary r24 r7 r17.project4 into r25;
    is.eq r14 5u16 into r26;
    ternary r26 r7 r17.project5 into r27;
    is.eq r14 6u16 into r28;
    ternary r28 r7 r17.project6 into r29;
    is.eq r14 7u16 into r30;
    ternary r30 r7 r17.project7 into r31;
    is.eq r14 8u16 into r32;
    ternary r32 r7 r17.project8 into r33;
    is.eq r14 9u16 into r34;
    ternary r34 r7 r17.project9 into r35;
    is.eq r14 10u16 into r36;
    ternary r36 r7 r17.project10 into r37;
    is.eq r14 11u16 into r38;
    ternary r38 r7 r17.project11 into r39;
    is.eq r14 12u16 into r40;
    ternary r40 r7 r17.project12 into r41;
    is.eq r14 13u16 into r42;
    ternary r42 r7 r17.project13 into r43;
    is.eq r14 14u16 into r44;
    ternary r44 r7 r17.project14 into r45;
    is.eq r14 15u16 into r46;
    ternary r46 r7 r17.project15 into r47;
    cast r19 r21 r23 r25 r27 r29 r31 r33 r35 r37 r39 r41 r43 r45 r47 into r48 as RoundProjectIds;
    cast r13.total_rounds into r49 as u64;
    set r48 into round_project_ids[r49];

function upgrade_stage:
    input r0 as field.public;
    input r1 as address.public;
    async upgrade_stage r0 r1 into r2;
    output r2 as dao_test.aleo/upgrade_stage.future;

finalize upgrade_stage:
    input r0 as field.public;
    input r1 as address.public;
    get project_info[r0] into r2;
    assert.eq r2.project_owner r1;
    get round_info[1u8] into r3;
    add r3.active_project_count 1u16 into r4;
    set r0 into active_project_info[r4];

function fund_private:
    input r0 as u64.private;
    input r1 as field.private;
    input r2 as address.private;
    input r3 as u64.private;
    input r4 as credits.aleo/credits.record;
    input r5 as u8.private;
    div r0 r3 into r6;
    cast self.caller r6 r1 r5 into r7 as Claimable.record;
    call credits.aleo/transfer_private r4 r2 r0 into r8 r9;
    async fund_private r0 r1 r2 r3 r5 into r10;
    output r8 as credits.aleo/credits.record;
    output r9 as credits.aleo/credits.record;
    output r7 as Claimable.record;
    output r10 as dao_test.aleo/fund_private.future;

finalize fund_private:
    input r0 as u64.public;
    input r1 as field.public;
    input r2 as address.public;
    input r3 as u64.public;
    input r4 as u8.public;
    get round_info[1u8] into r5;
    get is_round_active[r5.total_rounds] into r6;
    assert.eq r6 true;
    get project_info[r1] into r7;
    assert.eq r7.info.treasury_address r2;
    assert.eq r7.info.funding_target r3;
    assert.eq r7.info.stage r4;
    add r7.info.funded_amount r0 into r8;
    lt r7.info.funding_target r8 into r9;
    assert.eq r9 true;
    add r7.info.funded_amount r0 into r10;
    cast r7.info.title r7.info.image r7.info.description r7.info.funding_target r10 r7.info.treasury_address r7.info.stage r7.info.reserved_share into r11 as ProjectInfo;
    cast r7.id r7.project_owner r11 into r12 as Project;
    set r12 into project_info[r1];

function fund_public:
    input r0 as u64.public;
    input r1 as field.public;
    input r2 as address.public;
    input r3 as u64.public;
    div r0 r3 into r4;
    call credits.aleo/transfer_public_as_signer r2 r0 into r5;
    async fund_public r5 r0 r1 r2 r3 r4 self.caller into r6;
    output r6 as dao_test.aleo/fund_public.future;

finalize fund_public:
    input r0 as credits.aleo/transfer_public_as_signer.future;
    input r1 as u64.public;
    input r2 as field.public;
    input r3 as address.public;
    input r4 as u64.public;
    input r5 as u64.public;
    input r6 as address.public;
    get round_info[1u8] into r7;
    get is_round_active[r7.total_rounds] into r8;
    assert.eq r8 true;
    await r0;
    get project_info[r2] into r9;
    assert.eq r9.info.treasury_address r3;
    assert.eq r9.info.funding_target r4;
    add r9.info.funded_amount r1 into r10;
    lt r9.info.funding_target r10 into r11;
    assert.eq r11 true;
    add r9.info.funded_amount r1 into r12;
    cast r9.info.title r9.info.image r9.info.description r9.info.funding_target r12 r9.info.treasury_address r9.info.stage r9.info.reserved_share into r13 as ProjectInfo;
    cast r6 r5 r2 r9.info.stage into r14 as Claims;
    cast r6 r2 r9.info.stage into r15 as ClaimKeyGen;
    hash.bhp256 r15 into r16 as field;
    set r14 into public_investor_share[r16];
    cast r9.id r9.project_owner r13 into r17 as Project;
    set r17 into project_info[r2];

function combine_single_claim:
    input r0 as Claimable.record;
    input r1 as u64.private;
    assert.eq r0.owner self.caller;
    cast r0.owner 0u64 r0.project_id 0u8 into r2 as Claimable.record;
    cast r1 into r3 as u128;
    mul r3 1_000_000_000_000_000u128 into r4;
    sub 1_000_000_000_000_000u128 r4 into r5;
    cast r0.amount into r6 as u128;
    mul r6 r5 into r7;
    div r7 100u128 into r8;
    call token_registry.aleo/mint_private r0.project_id self.caller r8 false 4294967295u32 into r9 r10;
    async combine_single_claim r0.owner r0.project_id r1 r10 into r11;
    output r2 as Claimable.record;
    output r9 as token_registry.aleo/Token.record;
    output r11 as dao_test.aleo/combine_single_claim.future;

finalize combine_single_claim:
    input r0 as address.public;
    input r1 as field.public;
    input r2 as u64.public;
    input r3 as token_registry.aleo/mint_private.future;
    get project_info[r1] into r4;
    assert.eq r4.info.reserved_share r2;
    get round_info[1u8] into r5;
    get is_round_active[r5.total_rounds] into r6;
    assert.eq r6 true;
    await r3;

function combine_two_claims:
    input r0 as Claimable.record;
    input r1 as Claimable.record;
    input r2 as u64.private;
    assert.eq r0.owner r1.owner;
    assert.eq r0.owner self.caller;
    add r0.amount r1.amount into r3;
    cast r0.owner 0u64 r0.project_id 0u8 into r4 as Claimable.record;
    cast r2 into r5 as u128;
    mul r5 1_000_000_000_000_000u128 into r6;
    sub 1_000_000_000_000_000u128 r6 into r7;
    cast r3 into r8 as u128;
    mul r8 r7 into r9;
    div r9 100u128 into r10;
    call token_registry.aleo/mint_private r0.project_id self.caller r10 false 4294967295u32 into r11 r12;
    async combine_two_claims r0.owner r0.project_id r2 r12 into r13;
    output r4 as Claimable.record;
    output r11 as token_registry.aleo/Token.record;
    output r13 as dao_test.aleo/combine_two_claims.future;

finalize combine_two_claims:
    input r0 as address.public;
    input r1 as field.public;
    input r2 as u64.public;
    input r3 as token_registry.aleo/mint_private.future;
    get project_info[r1] into r4;
    assert.eq r4.info.reserved_share r2;
    get round_info[1u8] into r5;
    get is_round_active[r5.total_rounds] into r6;
    assert.eq r6 true;
    await r3;

function combine_three_claims:
    input r0 as Claimable.record;
    input r1 as Claimable.record;
    input r2 as Claimable.record;
    input r3 as u64.private;
    assert.eq r0.owner r1.owner;
    assert.eq r1.owner r2.owner;
    assert.eq r0.owner self.caller;
    add r0.amount r1.amount into r4;
    add r4 r2.amount into r5;
    cast r0.owner 0u64 r0.project_id 0u8 into r6 as Claimable.record;
    cast r3 into r7 as u128;
    mul r7 1_000_000_000_000_000u128 into r8;
    sub 1_000_000_000_000_000u128 r8 into r9;
    cast r5 into r10 as u128;
    mul r10 r9 into r11;
    div r11 100u128 into r12;
    call token_registry.aleo/mint_private r0.project_id self.caller r12 false 4294967295u32 into r13 r14;
    async combine_three_claims r0.owner r0.project_id r3 r14 into r15;
    output r6 as Claimable.record;
    output r13 as token_registry.aleo/Token.record;
    output r15 as dao_test.aleo/combine_three_claims.future;

finalize combine_three_claims:
    input r0 as address.public;
    input r1 as field.public;
    input r2 as u64.public;
    input r3 as token_registry.aleo/mint_private.future;
    get project_info[r1] into r4;
    assert.eq r4.info.reserved_share r2;
    get round_info[1u8] into r5;
    get is_round_active[r5.total_rounds] into r6;
    assert.eq r6 true;
    await r3;

function claim_public:
    input r0 as field.public;
    input r1 as u64.public;
    input r2 as u128.public;
    input r3 as u8.private;
    cast self.caller r0 r3 into r4 as ClaimKeyGen;
    cast r1 into r5 as u128;
    mul r5 1_000_000_000_000_000u128 into r6;
    sub 1_000_000_000_000_000u128 r6 into r7;
    mul r2 r7 into r8;
    div r8 100u128 into r9;
    hash.bhp256 r4 into r10 as field;
    call token_registry.aleo/mint_public r0 self.caller r9 4294967295u32 into r11;
    async claim_public self.caller r0 r10 r1 r2 r3 r11 into r12;
    output r12 as dao_test.aleo/claim_public.future;

finalize claim_public:
    input r0 as address.public;
    input r1 as field.public;
    input r2 as field.public;
    input r3 as u64.public;
    input r4 as u128.public;
    input r5 as u8.public;
    input r6 as token_registry.aleo/mint_public.future;
    get project_info[r1] into r7;
    assert.eq r7.info.reserved_share r3;
    assert.eq r7.info.stage r5;
    get round_info[1u8] into r8;
    get is_round_active[r8.total_rounds] into r9;
    assert.eq r9 true;
    get public_investor_share[r2] into r10;
    assert.eq r10.claim_owner r0;
    cast r10.amount into r11 as u128;
    assert.eq r11 r4;
    await r6;
    remove public_investor_share[r2];
