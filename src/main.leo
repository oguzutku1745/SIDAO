// The 'dao_test' program.
import credits.aleo;
import token_registry.aleo;

program dao_test.aleo {

    const admin_address: address = aleo1rhgdu77hgyqd3xjj8ucu3jj9r2krwz6mnzyd80gncr5fxcwlh5rsvzp9px;
    const epoch_interval: u128 = 123_u128;
    const s1_funding_limit: u64 = 10000u64;
    const s2_funding_limit: u64 = 20000u64;
    const s3_funding_limit: u64 = 30000u64;
    const round_constant: u8 = 1u8;

    record Claimable {
        owner: address,
        amount: u64,
        project_id: field,
        stage: u8
    }

    struct ClaimKeyGen {
        claim_owner: address,
        project_id: field,
        stage: u8
    }

    struct Project {
        id: field,
        project_owner: address,
        info: ProjectInfo
    }

    struct Claims {
        claim_owner:address,
        amount: u64,
        project_id:field,
        stage: u8
    }

    struct ProjectInfo {
        title: u128,
        image: u128,
        description: field,
        funding_target: u64,
        funded_amount: u64,
        treasury_address: address,
        stage:u8,
        reserved_share: u64
    }


    struct RoundProjectIds {
        project1: field,
        project2: field,
        project3: field,
        project4: field,
        project5: field,
        project6: field,
        project7: field,
        project8: field,
        project9: field,
        project10: field,
        project11: field,
        project12: field,
        project13: field,
        project14: field,
        project15: field,
    }

    struct Round {
        total_rounds: u32,
        active_project_count: u16,
        total_project_count: u64
    }

    
    // To fetch the current round information
    mapping round_info: u8 => Round;
    // To fetch the previous round informations
    mapping round_project_ids: u64 => RoundProjectIds;
    // To fetch the project information
    mapping project_info: field => Project;
    // To check the epoch situation
    mapping is_round_active: u32 => bool;
    // To identify the shares of the investor
    mapping public_investor_share: field => Claims;


    // OPEN THE ROUND
    async transition init_round() -> Future {
        assert_eq(self.caller, admin_address);
        return init_round_finalize(self.caller);
    }

    async function init_round_finalize(public caller:address){

        Mapping::set(round_info, round_constant, Round {
            total_rounds: 0u32,
            active_project_count: 0u16,
            total_project_count: 0u64
        });
    } 

    async transition open_new_round(public current_round:u32) -> Future {

        let projectIds:RoundProjectIds = RoundProjectIds {
                project1: 0field,
                project2: 0field,
                project3: 0field,
                project4: 0field,
                project5: 0field,
                project6: 0field,
                project7: 0field,
                project8: 0field,
                project9: 0field,
                project10: 0field,
                project11: 0field,
                project12: 0field,
                project13: 0field,
                project14: 0field,
                project15: 0field,
            };

        assert_eq(self.caller, admin_address);

        return open_round_finalize(current_round, projectIds);
    }

    async function open_round_finalize(public current_round:u32, public projectIds: RoundProjectIds) {
        
        let current_round_details : Round = Mapping::get(round_info, round_constant);
        assert_eq(current_round_details.total_rounds, current_round);

        let is_active:bool = Mapping::get(is_round_active, current_round);

        assert_eq(is_active, false);
        Mapping::set(is_round_active, current_round, true);
        Mapping::set(round_project_ids, current_round_details.total_rounds as u64 + 1u64, projectIds);

        Mapping::set(round_info, round_constant, Round{
            total_rounds: current_round_details.total_rounds + 1u32,
            active_project_count: 0u16,
            total_project_count: current_round_details.total_project_count
        });
    }


    // CLOSE THE ROUND (THIS WİLL START VOTİNG PERİOD IN FUTURE)
    async transition close_round(public caller: address) -> Future {

        assert_eq(self.caller, admin_address);


        return close_round_finalize(self.caller);
    }

    async function close_round_finalize(public caller:address) {

        let current_round_details : Round = Mapping::get(round_info, round_constant);
        let is_active:bool = Mapping::get(is_round_active, current_round_details.total_rounds);

        assert_eq(is_active, true);
        Mapping::set(is_round_active, current_round_details.total_rounds, false);

        let closed_round: Round = Round{
            total_rounds: current_round_details.total_rounds,
            active_project_count: 0u16,
            total_project_count: current_round_details.total_project_count,
        };

        Mapping::set(round_info, round_constant, closed_round);
    }

    // CREATE A PROJECT (IMPLEMENT ZPASS)
    async transition submit_project(
        public creator_address:address,
        public treasury_address: address,
        public title: u128,
        public image_link: u128,
        public description: field,
        public stage:u8,
        public target_funding:u64,
        public project_name: u128,
        public symbol: u128,
        public reserved_share: u64
        ) -> Future {

        // Derive project details
        let project_details : ProjectInfo = ProjectInfo{
            title: title,
            image: image_link,
            description: description,
            funding_target: target_funding,
            funded_amount: 0u64,
            treasury_address: treasury_address,
            stage: stage,
            reserved_share: reserved_share,
        };

        // Create the project_id from ProjectInfo struct
        let project_id:field = BHP256::hash_to_field(project_details);

        assert(
            target_funding < (
                stage == 1u8 
                    ? s1_funding_limit 
                    : (stage == 2u8 || stage == 3u8 
                        ? s2_funding_limit 
                        : 0u64)
            )
        );

        let r0: Future = token_registry.aleo/register_token(
              project_id, 
              project_name, // name: u128, TEST ascii encoded
              symbol, // symbol: u128, TST ascii encoded
              6u8, // decimals: u8
              1_000_000_000_000_000u128, // max_supply: u128
              false, // external_authorization_required: boolean
              dao_test.aleo // external_authorization_party: address
            );
            let r1: Future = token_registry.aleo/set_role(
              project_id, 
              dao_test.aleo,
              3u8
            );

        return submit_project_finalize(creator_address, treasury_address, title, image_link, description, stage, target_funding, project_id, project_details, r0, r1);
    }

    async function submit_project_finalize(public creator_address: address, public treasury_address: address, public title: u128, public image_link: u128, public description:field, public stage:u8, public target_funding: u64, public project_id: field, public project_details: ProjectInfo, r0:Future, r1:Future) {
        let current_round_details : Round = Mapping::get(round_info, round_constant);
        let round_status:bool = Mapping::get(is_round_active, current_round_details.total_rounds);
        assert(round_status);

        r0.await();
        r1.await();
        // Fetch project index in the current round
        let round_details:Round = Mapping::get(round_info,round_constant);
        let project_index:u16 = round_details.active_project_count + 1u16;

        let project_submission:Project = Project {
            id: project_id,
            project_owner: creator_address,
            info: project_details
        };

        // Set the info mapping to be able to fetch details later
        Mapping::set(project_info, project_id, project_submission);

        let round_projects: RoundProjectIds = Mapping::get(round_project_ids, round_details.total_rounds as u64);

        let submit_round_id:RoundProjectIds = RoundProjectIds {
            project1: project_index == 1u16 ? project_id : round_projects.project1,
            project2: project_index == 2u16 ? project_id : round_projects.project2,
            project3: project_index == 3u16 ? project_id : round_projects.project3,
            project4: project_index == 4u16 ? project_id : round_projects.project4,
            project5: project_index == 5u16 ? project_id : round_projects.project5,
            project6: project_index == 6u16 ? project_id : round_projects.project6,
            project7: project_index == 7u16 ? project_id : round_projects.project7,
            project8: project_index == 8u16 ? project_id : round_projects.project8,
            project9: project_index == 9u16 ? project_id : round_projects.project9,
            project10: project_index == 10u16 ? project_id : round_projects.project10,
            project11: project_index == 11u16 ? project_id : round_projects.project11,
            project12: project_index == 12u16 ? project_id : round_projects.project12,
            project13: project_index == 13u16 ? project_id : round_projects.project13,
            project14: project_index == 14u16 ? project_id : round_projects.project14,
            project15: project_index == 15u16 ? project_id : round_projects.project15,
        };

        Mapping::set(round_project_ids, round_details.total_rounds as u64, submit_round_id);

    }

    // INCREASE THE STAGE OF THE PROJECT FOR THE NEXT ROUNDS
    async transition upgrade_stage(public project_id:field, public project_owner:address) -> Future {

        return upgrade_stage_finalize(project_id, project_owner);
    }

    async function upgrade_stage_finalize(public project_id:field, public project_owner:address) {

        let project_details:Project = Mapping::get(project_info, project_id);

        assert_eq(project_details.project_owner, project_owner);

        let round_details:Round = Mapping::get(round_info,round_constant);
        let project_index:u16 = round_details.active_project_count + 1u16;

        let round_projects: RoundProjectIds = Mapping::get(round_project_ids, round_details.total_rounds as u64);

        let submit_round_id:RoundProjectIds = RoundProjectIds {
            project1: project_index == 1u16 ? project_id : round_projects.project1,
            project2: project_index == 2u16 ? project_id : round_projects.project2,
            project3: project_index == 3u16 ? project_id : round_projects.project3,
            project4: project_index == 4u16 ? project_id : round_projects.project4,
            project5: project_index == 5u16 ? project_id : round_projects.project5,
            project6: project_index == 6u16 ? project_id : round_projects.project6,
            project7: project_index == 7u16 ? project_id : round_projects.project7,
            project8: project_index == 8u16 ? project_id : round_projects.project8,
            project9: project_index == 9u16 ? project_id : round_projects.project9,
            project10: project_index == 10u16 ? project_id : round_projects.project10,
            project11: project_index == 11u16 ? project_id : round_projects.project11,
            project12: project_index == 12u16 ? project_id : round_projects.project12,
            project13: project_index == 13u16 ? project_id : round_projects.project13,
            project14: project_index == 14u16 ? project_id : round_projects.project14,
            project15: project_index == 15u16 ? project_id : round_projects.project15,
        };

        Mapping::set(round_project_ids, round_details.total_rounds as u64, submit_round_id);
    }

    // FUND A PROJECT

    async transition fund_private(amount: u64, project_id: field, receiver:address, funding_target:u64, credits:credits.aleo/credits, stage:u8) -> (credits.aleo/credits, credits.aleo/credits, Claimable, Future) {
        
        let pool_share:u64 = amount / funding_target;  

        let claim_amount:Claimable = Claimable {
            owner: self.caller,
            amount: pool_share,
            project_id: project_id,
            stage: stage
        };
        let (remaining_record, funding_record) : (credits.aleo/credits, credits.aleo/credits) = credits.aleo/transfer_private(credits, receiver, amount);

        return (remaining_record, funding_record, claim_amount, finalize_fund_private(amount, project_id, receiver, funding_target, stage));
    }

    async function finalize_fund_private(amount:u64, project_id:field, receiver:address, funding_target: u64, stage: u8) {
        let current_round_details : Round = Mapping::get(round_info, round_constant);
        let round_status:bool = Mapping::get(is_round_active, current_round_details.total_rounds);
        assert(round_status);
        let project_details:Project = Mapping::get(project_info, project_id);
        assert_eq(project_details.info.treasury_address, receiver);
        assert_eq(project_details.info.funding_target, funding_target);
        assert_eq(project_details.info.stage, stage);
        assert(project_details.info.funding_target < project_details.info.funded_amount + amount);

        let updated_amount:u64 = project_details.info.funded_amount + amount;

        let updated_info:ProjectInfo = ProjectInfo {
            title: project_details.info.title,
            image: project_details.info.image,
            description: project_details.info.description,
            funding_target: project_details.info.funding_target,
            funded_amount: updated_amount,
            treasury_address: project_details.info.treasury_address,
            stage: project_details.info.stage,
            reserved_share: project_details.info.reserved_share
        };

        Mapping::set(project_info, project_id, Project{
            id: project_details.id,
            project_owner: project_details.project_owner,
            info: updated_info
        });
    }

    // - Public fund

    async transition fund_public(public amount:u64,public project_id: field, public receiver:address, public funding_target:u64) -> Future {
        let pool_share:u64 = amount / funding_target;
        let f0: Future = credits.aleo/transfer_public_as_signer(receiver, amount);

        return finalize_fund_public(f0, amount, project_id, receiver, funding_target, pool_share, self.caller);
    }

    async function finalize_fund_public(public f0:Future, public amount:u64,public project_id: field, public receiver:address, public funding_target:u64, public pool_share:u64, public caller:address) {
        let current_round_details : Round = Mapping::get(round_info, round_constant);
        let round_status:bool = Mapping::get(is_round_active, current_round_details.total_rounds);
        assert(round_status);

        f0.await();

        let project_details:Project = Mapping::get(project_info, project_id);
        assert_eq(project_details.info.treasury_address, receiver);
        assert_eq(project_details.info.funding_target, funding_target);
        assert(project_details.info.funding_target < project_details.info.funded_amount + amount);

        let updated_amount:u64 = project_details.info.funded_amount + amount;

        let updated_info:ProjectInfo = ProjectInfo {
            title: project_details.info.title,
            image: project_details.info.image,
            description: project_details.info.description,
            funding_target: project_details.info.funding_target,
            funded_amount: updated_amount,
            treasury_address: project_details.info.treasury_address,
            stage: project_details.info.stage,
            reserved_share: project_details.info.reserved_share
        };

        let claim_amount: Claims = Claims {
            claim_owner: caller,
            amount: pool_share,
            project_id: project_id,
            stage: project_details.info.stage
        };

        // Generate claim key w.r.t each stage differently.
        let claim_key_generator:ClaimKeyGen = ClaimKeyGen{
            claim_owner: caller,
            project_id: project_id,
            stage: project_details.info.stage
        };

        let claim_key:field = BHP256::hash_to_field(claim_key_generator);
        Mapping::set(public_investor_share, claim_key, claim_amount);

        Mapping::set(project_info, project_id, Project{
            id: project_details.id,
            project_owner: project_details.project_owner,
            info: updated_info
        });
    }

    // CLAIM YOUR SHARE
    async transition combine_single_claim(c1: Claimable, reserved_share: u64) -> (Claimable, token_registry.aleo/Token, Future) {

        assert_eq(c1.owner, self.caller);
        let final_share:u64 = c1.amount;
        let claim_owner:address = c1.owner;
        let project_id:field = c1.project_id;

        let spent_claim: Claimable = Claimable {
            owner: c1.owner,
            amount: 0u64,
            project_id: c1.project_id,
            stage: 0u8
        };

        let fundable_tokens:u128 = 1_000_000_000_000_000u128 - (reserved_share as u128 * 1_000_000_000_000_000u128);
        let to_mint:u128 = (((final_share as u128) * fundable_tokens) / 100u128);

        let (token, f0): (token_registry.aleo/Token,Future) = token_registry.aleo/mint_private(project_id, self.caller, to_mint, false,  4294967295u32);

        return (spent_claim, token, claim(claim_owner, project_id, reserved_share, f0));
    }

    async transition combine_two_claims(c1: Claimable, c2:Claimable, reserved_share: u64) -> (Claimable, token_registry.aleo/Token, Future) {

        assert_eq(c1.owner, c2.owner);
        assert_eq(c1.owner, self.caller);
        let final_share:u64 = c1.amount + c2.amount;
        let claim_owner:address = c1.owner;
        let project_id:field = c1.project_id;

        let spent_claim: Claimable = Claimable {
            owner: c1.owner,
            amount: 0u64,
            project_id: c1.project_id,
            stage: 0u8
        };

        let fundable_tokens:u128 = 1_000_000_000_000_000u128 - (reserved_share as u128 * 1_000_000_000_000_000u128);
        let to_mint:u128 = (((final_share as u128) * fundable_tokens) / 100u128);

        let (token, f0): (token_registry.aleo/Token,Future) = token_registry.aleo/mint_private(project_id, self.caller, to_mint, false,  4294967295u32);

        return (spent_claim, token, claim(claim_owner, project_id, reserved_share, f0));
    }


    async transition combine_three_claims(c1:Claimable, c2:Claimable, c3:Claimable, reserved_share: u64) -> (Claimable, token_registry.aleo/Token, Future) {

        assert_eq(c1.owner, c2.owner);
        assert_eq(c2.owner, c3.owner);
        assert_eq(c1.owner, self.caller);

        let final_share:u64 = c1.amount + c2.amount + c3.amount;
        let claim_owner:address = c1.owner;
        let project_id:field = c1.project_id;

        let spent_claim: Claimable = Claimable {
            owner: c1.owner,
            amount: 0u64,
            project_id: c1.project_id,
            stage: 0u8
        };

        let fundable_tokens:u128 = 1_000_000_000_000_000u128 - (reserved_share as u128 * 1_000_000_000_000_000u128);
        let to_mint:u128 = (((final_share as u128) * fundable_tokens) / 100u128);

        let (token, f0): (token_registry.aleo/Token,Future) = token_registry.aleo/mint_private(project_id, self.caller, to_mint, false,  4294967295u32);

        return (spent_claim, token, claim(claim_owner, project_id, reserved_share, f0));

    }

    async function claim(claim_owner:address, project_id:field, reserved_share: u64, f0: Future) {

        let project_details:Project = Mapping::get(project_info, project_id);
        assert_eq(project_details.info.reserved_share, reserved_share);

        let current_round_details : Round = Mapping::get(round_info, round_constant);
        let round_status:bool = Mapping::get(is_round_active, current_round_details.total_rounds);
        assert(round_status);

        f0.await();

    }

    async transition claim_public(public project_id: field, public reserved_share:u64, public amount:u128, stage:u8) -> Future {
        
        let claim_key_generator:ClaimKeyGen = ClaimKeyGen{
            claim_owner: self.caller,
            project_id: project_id,
            stage: stage
        };

        let fundable_tokens:u128 = 1_000_000_000_000_000u128 - (reserved_share as u128 * 1_000_000_000_000_000u128);
        let to_mint:u128 = ((amount * fundable_tokens) / 100u128);

        let claim_key:field = BHP256::hash_to_field(claim_key_generator);

        let f0: Future = token_registry.aleo/mint_public(project_id, self.caller, to_mint, 4294967295u32);

        return claim_public_finalize(self.caller, project_id, claim_key, reserved_share, amount, stage, f0);
    }

    async function claim_public_finalize(public claim_owner: address, public project_id:field, public claim_key:field, public reserved_share:u64, public amount:u128, public stage:u8, f0:Future) {

        let project_details:Project = Mapping::get(project_info, project_id);
        assert_eq(project_details.info.reserved_share, reserved_share);
        assert_eq(project_details.info.stage, stage);

        let current_round_details : Round = Mapping::get(round_info, round_constant);
        let round_status:bool = Mapping::get(is_round_active, current_round_details.total_rounds);
        assert(round_status);

        let claim_params:Claims = Mapping::get(public_investor_share, claim_key);
        assert_eq(claim_params.claim_owner, claim_owner);
        assert_eq(claim_params.amount as u128, amount);

        f0.await();

        Mapping::remove(public_investor_share, claim_key);

    }

    // SET THE ROUND ( Passive for now )
}
